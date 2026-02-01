import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../services/firebase/firestore_service.dart';
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
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;
      if (interests != null) updateData['interests'] = interests;

      updateData['updatedAt'] = DateTime.now().toIso8601String();

      await _firestoreService.updateUser(userId, updateData);
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
