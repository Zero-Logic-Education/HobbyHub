import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Сервис для работы с Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Добавляем serverClientId для Google Sign-In на Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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
      print('Signing up with email: $email');
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Successfully signed up with email');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Вход с email и паролем
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Successfully signed in with email');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// Вход с Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Запуск процесса входа Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null; // Отмена пользователем
      }

      print('Google Sign-In: User selected - ${googleUser.email}');

      // 2. Получение данных аутентификации от Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google Sign-In: Got auth tokens');

      // 3. Создание учетных данных для Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Google Sign-In: Created Firebase credential');

      // 4. Вход в Firebase
      final result = await _auth.signInWithCredential(credential);
      print('Google Sign-In: Successfully signed in');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Вход с Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // 1. Запуск процесса входа Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // 2. Получение Access Token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        // 3. Вход в Firebase
        return await _auth.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        return null;
      } else {
        throw result.message ?? 'Unknown Facebook error';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
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
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
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
