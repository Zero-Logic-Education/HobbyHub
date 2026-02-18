import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  return user.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
  );
});

/// Enum для результатов авторизации
enum AuthResult {
  idle,
  loading,
  success,
  failure,
}

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
      () => _authService.signInWithEmail(
        email: email,
        password: password,
      ),
    );
  }

  /// Регистрация с email и паролем
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.signUpWithEmail(
        email: email,
        password: password,
      ),
    );
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
