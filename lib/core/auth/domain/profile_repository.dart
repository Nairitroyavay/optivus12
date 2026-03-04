import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/auth/domain/profile_data.dart';

/// Contract for profile operations.
/// Providers depend ONLY on this interface — never on Firebase directly.
abstract class ProfileRepository {
  /// Ensures a profile document exists for [uid].
  /// Creates one with defaults if missing (idempotent via merge).
  Future<Either<Failure, ProfileData>> ensureProfile(String uid);

  /// Fetches the profile for [uid].
  Future<Either<Failure, ProfileData>> getProfile(String uid);

  /// Marks onboarding complete for [uid].
  Future<Either<Failure, void>> markOnboardingComplete(String uid);
}
