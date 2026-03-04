import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:optivus/core/auth/data/profile_remote_datasource.dart';
import 'package:optivus/core/auth/data/profile_repository_impl.dart';

import 'package:optivus/core/failures/failure.dart';

// ─── Mocks ─────────────────────────────────────────────────────
class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late MockProfileRemoteDataSource mockDataSource;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockDataSource);
  });

  group('ensureProfile', () {
    const uid = 'test-user-123';

    test('returns ProfileData on success (new user)', () async {
      // Arrange: datasource returns minimal profile for new user
      when(() => mockDataSource.ensureProfile(uid)).thenAnswer(
        (_) async => {'onboarding_complete': false, 'schema_version': 1},
      );

      // Act
      final result = await repository.ensureProfile(uid);

      // Assert
      expect(result.isRight(), true);
      final profile = result.getOrElse(
        (_) => throw Exception('Expected Right'),
      );
      expect(profile.isOnboardingComplete, false);
      verify(() => mockDataSource.ensureProfile(uid)).called(1);
    });

    test(
      'returns ProfileData with onboarding=true for existing user',
      () async {
        when(() => mockDataSource.ensureProfile(uid)).thenAnswer(
          (_) async => {
            'onboarding_complete': true,
            'schema_version': 1,
            'created_at': DateTime(2025, 1, 1),
          },
        );

        final result = await repository.ensureProfile(uid);

        expect(result.isRight(), true);
        final profile = result.getOrElse(
          (_) => throw Exception('Expected Right'),
        );
        expect(profile.isOnboardingComplete, true);
        expect(profile.createdAt, isNotNull);
      },
    );

    test('returns ServerFailure on FirebaseException', () async {
      when(() => mockDataSource.ensureProfile(uid)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'Permission denied',
          code: 'permission-denied',
        ),
      );

      final result = await repository.ensureProfile(uid);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on unexpected exception', () async {
      when(
        () => mockDataSource.ensureProfile(uid),
      ).thenThrow(Exception('Network timeout'));

      final result = await repository.ensureProfile(uid);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'An unexpected error occurred.');
      }, (_) => fail('Expected Left'));
    });
  });

  group('markOnboardingComplete', () {
    const uid = 'test-user-123';

    test('returns Right(null) on success', () async {
      when(
        () => mockDataSource.markOnboardingComplete(uid),
      ).thenAnswer((_) async {});

      final result = await repository.markOnboardingComplete(uid);

      expect(result.isRight(), true);
      verify(() => mockDataSource.markOnboardingComplete(uid)).called(1);
    });

    test('returns ServerFailure on FirebaseException', () async {
      when(() => mockDataSource.markOnboardingComplete(uid)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'Deadline exceeded',
          code: 'deadline-exceeded',
        ),
      );

      final result = await repository.markOnboardingComplete(uid);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on unexpected exception', () async {
      when(
        () => mockDataSource.markOnboardingComplete(uid),
      ).thenThrow(Exception('Unexpected'));

      final result = await repository.markOnboardingComplete(uid);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'An unexpected error occurred.');
      }, (_) => fail('Expected Left'));
    });
  });
}
