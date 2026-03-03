import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/logger/app_logger.dart';
import 'package:optivus/core/auth/domain/profile_data.dart';
import 'package:optivus/core/auth/domain/profile_repository.dart';
import 'package:optivus/core/auth/data/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ProfileData>> ensureProfile(String uid) async {
    try {
      final json = await _dataSource.ensureProfile(uid);
      return Right(_mapToProfileData(json));
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to ensure profile for $uid', e);
      return Left(ServerFailure('Failed to initialize your profile.'));
    } catch (e, st) {
      AppLogger.error('Unexpected error ensuring profile', e, st);
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileData>> getProfile(String uid) async {
    try {
      final json = await _dataSource.getProfile(uid);
      if (json == null) {
        return const Right(ProfileData(isOnboardingComplete: false));
      }
      return Right(_mapToProfileData(json));
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to get profile for $uid', e);
      return Left(ServerFailure('Failed to load your profile.'));
    } catch (e, st) {
      AppLogger.error('Unexpected error getting profile', e, st);
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> markOnboardingComplete(String uid) async {
    try {
      await _dataSource.markOnboardingComplete(uid);
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to mark onboarding complete for $uid', e);
      return Left(ServerFailure('Failed to save your progress.'));
    } catch (e, st) {
      AppLogger.error('Unexpected error completing onboarding', e, st);
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  ProfileData _mapToProfileData(Map<String, dynamic> json) {
    return ProfileData(
      isOnboardingComplete: json['onboarding_complete'] == true,
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // Firestore Timestamps have a toDate() method
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }
}
