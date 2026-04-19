import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Провайдер для Firebase Auth Service
final authServiceProvider = Provider((ref) => AuthService());

/// Провайдер для отслеживания состояния авторизации
final authStateProvider = StreamProvider<fb.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Провайдер для текущего пользователя (если авторизован)
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider);
  return user.maybeWhen(data: (user) => user?.uid, orElse: () => null);
});

/// Enum для результатов авторизации
enum AuthResult { idle, loading, success, failure }

/// Класс для результата авторизации с ошибкой
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// State notifier для управления процессом авторизации
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  /// Вход с email и паролем
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signInWithEmail(email: email, password: password),
    );
  }

  /// Регистрация с email и паролем
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signUpWithEmail(email: email, password: password),
    );
  }

  /// Вход через Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cred = await _authService.signInWithGoogle();
      if (cred != null) {
        await _ensureUserDocExists(cred.user);
      }
    });
  }

  /// Вход через Facebook
  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cred = await _authService.signInWithFacebook();
      if (cred != null) {
        await _ensureUserDocExists(cred.user);
      }
    });
  }

  Future<void> _ensureUserDocExists(fb.User? user) async {
    if (user == null) return;
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      final email = user.email ?? '';
      String username = user.displayName?.trim() ?? '';
      if (username.isEmpty && email.contains('@')) {
        username = email.split('@').first;
      }
      if (username.isEmpty) {
        username = 'user_${user.uid.substring(0, 5)}';
      }

      final now = DateTime.now().toIso8601String();

      await firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'username': username,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'bio': null,
        'age': null, // НЕ устанавливаем возраст автоматически
        'interests': <String>[],
        'privacyLevel': 'public',
        'latitude': null,
        'longitude': null,
        'isVerified': false, // Требуется верификация возраста
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }

  /// Отправить email для сброса пароля
  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.sendPasswordResetEmail(email),
    );
  }
}

/// Провайдер для управления авторизацией
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthNotifier(authService);
    });

/// Провайдер для проверки авторизации пользователя
final isLoggedInProvider = Provider<bool>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  return currentUserId != null;
});

/// Провайдер для отслеживания ошибок авторизации
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    error: (error, stackTrace) => error.toString(),
    orElse: () => null,
  );
});
