import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';

/// Result of a sign-up attempt.
sealed class AuthSignUpResult {
  const AuthSignUpResult();
}

/// The user was signed up and a session was created immediately.
class AuthSignUpConfirmed extends AuthSignUpResult {
  const AuthSignUpConfirmed();
}

/// The user must verify their email before a session is created.
class AuthSignUpNeedsVerification extends AuthSignUpResult {
  const AuthSignUpNeedsVerification();
}

/// Contract for authentication operations.
/// Presentation depends ONLY on this interface — never on the implementation.
abstract class AuthRepository {
  Future<Either<AuthFailure, void>> signIn({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthSignUpResult>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<AuthFailure, void>> resetPassword({required String email});
}
