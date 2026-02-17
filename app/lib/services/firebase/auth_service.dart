import 'package:firebase_auth/firebase_auth.dart';

/// Сервис для работы с Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Получить текущего пользователя
  User? get currentUser => _auth.currentUser;

  /// Stream изменений состояния авторизации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Регистрация с email и паролем
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Вход с email и паролем
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Вход с Google
  Future<UserCredential?> signInWithGoogle() async {
    // Requires google_sign_in package
    throw UnimplementedError('Google Sign-In not implemented yet');
  }

  /// Вход с Apple
  Future<UserCredential?> signInWithApple() async {
    // Requires sign_in_with_apple package
    throw UnimplementedError('Apple Sign-In not implemented yet');
  }

  /// Отправить email для сброса пароля
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Отправить email верификации
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Удалить аккаунт
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Обновить профиль пользователя
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Обработка Firebase Auth исключений
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'email-already-in-use':
        return 'Email уже используется';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Пользователь заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      default:
        return 'Ошибка авторизации: ${e.message}';
    }
  }
}
