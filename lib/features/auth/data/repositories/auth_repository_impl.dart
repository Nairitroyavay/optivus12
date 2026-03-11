import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/logger/app_logger.dart';
import 'package:optivus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:optivus/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<AuthFailure, void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _dataSource.signIn(email: email, password: password);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Auth sign-in failed', e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } catch (e, st) {
      AppLogger.error('Unexpected sign-in error', e, st);
      return const Left(
        AuthFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Either<AuthFailure, AuthSignUpResult>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _dataSource.signUp(
        email: email,
        password: password,
        name: name,
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        // Send verification email before signing out so the user can verify.
        await user.sendEmailVerification();
        // Sign out immediately — the session is only granted after email verification.
        await FirebaseAuth.instance.signOut();
        return const Right(AuthSignUpNeedsVerification());
      }

      // Rare: already verified (e.g. social/federated auth) — let them in.
      return const Right(AuthSignUpConfirmed());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Auth sign-up failed', e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } catch (e, st) {
      AppLogger.error('Unexpected sign-up error', e, st);
      return const Left(
        AuthFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  @override
  Future<Either<AuthFailure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await _dataSource.resetPassword(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } catch (e, st) {
      AppLogger.error('Unexpected password reset error', e, st);
      return const Left(
        AuthFailure('An unexpected error occurred. Please try again.'),
      );
    }
  }

  /// Maps Firebase Auth error codes to user-safe messages.
  /// Prevents leaking infra details to the UI.
  String _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password does not meet the requirements.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
