import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _authCheck = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _authCheck.authStateChanges();

  User? get currentUser => _authCheck.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _authCheck.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _authCheck.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authCheck.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authCheck.sendPasswordResetEmail(email: email);
  }
}
