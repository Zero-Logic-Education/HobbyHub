import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../models/user.dart';
import '../../services/firebase/storage_service.dart';

import '../../services/firebase/firestore_service.dart';
import '../../core/constants/app_constants.dart';
import 'auth_provider.dart';

/// Провайдер для Firestore Service
final firestoreServiceProvider = Provider((ref) => FirestoreService());

/// Провайдер для получения текущего пользователя из Firestore
final currentUserProvider = FutureProvider<User?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  final docSnapshot = await firestoreService.getUser(userId);

  if (!docSnapshot.exists) return null;

  return User.fromJson(docSnapshot.data() as Map<String, dynamic>);
});

/// Stream провайдер для отслеживания изменений текущего пользователя в реальном времени
final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.userStream(userId).map((docSnapshot) {
    if (!docSnapshot.exists) return null;
    return User.fromJson(docSnapshot.data() as Map<String, dynamic>);
  });
});

/// Провайдер для проверки верификации возраста
final isAgeVerifiedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserStreamProvider);
  return userAsync.maybeWhen(
    data: (user) =>
        user != null && user.isVerified && user.age >= AppConstants.minAge,
    orElse: () => false,
  );
});

/// Провайдер для количества подписчиков текущего пользователя
final followersCountProvider = Provider<int>((ref) {
  final userAsync = ref.watch(currentUserStreamProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.friends.length ?? 0,
    orElse: () => 0,
  );
});

/// State notifier для управления профилем пользователя
class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final String userId;

  UserProfileNotifier(this._firestoreService, this.userId)
    : super(const AsyncValue.data(null));

  /// Обновить профиль пользователя
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? interests,
    String? parentEmail,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;
      if (interests != null) updateData['interests'] = interests;
      if (parentEmail != null) updateData['parentEmail'] = parentEmail;

      updateData['updatedAt'] = DateTime.now().toIso8601String();

      await _firestoreService.updateUser(userId, updateData);
    });
  }

  /// Обновить геолокацию пользователя
  Future<void> updateLocation(double latitude, double longitude) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firestoreService.updateUser(userId, {
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Добавить интерес к профилю
  Future<void> addInterest(String interestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = await _firestoreService.getUser(userId);
      if (!currentUser.exists) return;

      final userData = currentUser.data() as Map<String, dynamic>;
      final interests = List<String>.from(userData['interests'] ?? []);

      if (!interests.contains(interestId)) {
        interests.add(interestId);
        await _firestoreService.updateUser(userId, {
          'interests': interests,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Удалить интерес из профиля
  Future<void> removeInterest(String interestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = await _firestoreService.getUser(userId);
      if (!currentUser.exists) return;

      final userData = currentUser.data() as Map<String, dynamic>;
      final interests = List<String>.from(userData['interests'] ?? []);

      interests.removeWhere((id) => id == interestId);

      await _firestoreService.updateUser(userId, {
        'interests': interests,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
}

/// Провайдер для управления профилем пользователя
final userProfileNotifierProvider =
    StateNotifierProvider.family<UserProfileNotifier, AsyncValue<void>, String>(
      (ref, userId) {
        final firestoreService = ref.watch(firestoreServiceProvider);
        return UserProfileNotifier(firestoreService, userId);
      },
    );

/// Провайдер для профиля текущего пользователя
final currentUserProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final firestoreService = ref.watch(firestoreServiceProvider);
      return UserProfileNotifier(firestoreService, userId);
    });

/// State notifier для верификации возраста пользователя
class AgeVerificationNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final String _userId;

  AgeVerificationNotifier(this._firestoreService, this._userId)
    : super(const AsyncValue.data(null));

  Future<void> verifyAge({required int age}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (age < AppConstants.minAge) {
        throw Exception('Возраст меньше минимального');
      }

      final authUser = fb.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      final userDoc = await _firestoreService.getUser(_userId);
      final now = DateTime.now().toIso8601String();

      if (!userDoc.exists) {
        final email = authUser.email ?? '';
        final username = _deriveUsername(authUser);

        await _firestoreService.createUser(_userId, {
          'id': _userId,
          'email': email,
          'username': username,
          'displayName': authUser.displayName,
          'photoUrl': authUser.photoURL,
          'bio': null,
          'age': age,
          'interests': <String>[],
          'privacyLevel': AppConstants.privacyPublic,
          'latitude': null,
          'longitude': null,
          'isVerified': true,
          'createdAt': now,
          'updatedAt': now,
          'friends': <String>[],
          'eventsAttended': 0,
          'organizerRating': 0.0,
          'eventsCreated': 0,
        });
      } else {
        await _firestoreService.updateUser(_userId, {
          'age': age,
          'isVerified': true,
          'updatedAt': now,
        });
      }
    });
  }

  String _deriveUsername(fb.User authUser) {
    final displayName = authUser.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final email = authUser.email ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'user_${_userId.substring(0, 6)}';
  }
}

/// Провайдер для верификации возраста текущего пользователя
final ageVerificationNotifierProvider =
    StateNotifierProvider<AgeVerificationNotifier, AsyncValue<void>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final firestoreService = ref.watch(firestoreServiceProvider);
      return AgeVerificationNotifier(firestoreService, userId);
    });

/// Провайдер для получения любого пользователя по ID
final userProfileProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final docSnapshot = await firestoreService.getUser(userId);

  if (!docSnapshot.exists) return null;

  return User.fromJson(docSnapshot.data() as Map<String, dynamic>);
});

final storageServiceProvider = Provider((ref) => StorageService());
