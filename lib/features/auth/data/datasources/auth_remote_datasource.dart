import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Auth SDK.
/// Throws raw exceptions — the repository layer catches and maps them.
class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSource({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates a new user and sets displayName.
  /// Firebase Auth immediately confirms the account (no email verification gate).
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
