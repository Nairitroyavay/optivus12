import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optivus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:optivus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:optivus/features/auth/domain/repositories/auth_repository.dart';
import 'package:optivus/core/failures/failure.dart';

// ─── Mocks ─────────────────────────────────────────────────────
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('signIn', () {
    const email = 'test@optivus.com';
    const password = 'securePass123';

    test('returns Right(null) on successful sign-in', () async {
      when(
        () => mockDataSource.signIn(email: email, password: password),
      ).thenAnswer((_) async {});

      final result = await repository.signIn(email: email, password: password);

      expect(result.isRight(), true);
      verify(
        () => mockDataSource.signIn(email: email, password: password),
      ).called(1);
    });

    test(
      'returns AuthFailure with user-safe message on wrong password',
      () async {
        when(
          () => mockDataSource.signIn(email: email, password: password),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        final result = await repository.signIn(
          email: email,
          password: password,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Incorrect email or password.');
        }, (_) => fail('Expected Left'));
      },
    );

    test('returns AuthFailure on unexpected error', () async {
      when(
        () => mockDataSource.signIn(email: email, password: password),
      ).thenThrow(Exception('Network timeout'));

      final result = await repository.signIn(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(
          failure.message,
          'An unexpected error occurred. Please try again.',
        );
      }, (_) => fail('Expected Left'));
    });
  });

  group('signUp', () {
    const email = 'new@optivus.com';
    const password = 'securePass123';
    const name = 'Test User';

    test('returns AuthSignUpConfirmed on successful sign-up', () async {
      when(
        () =>
            mockDataSource.signUp(email: email, password: password, name: name),
      ).thenAnswer((_) async => MockUserCredential());

      final result = await repository.signUp(
        email: email,
        password: password,
        name: name,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (signUpResult) => expect(signUpResult, isA<AuthSignUpConfirmed>()),
      );
    });

    test('returns AuthFailure on email-already-in-use', () async {
      when(
        () =>
            mockDataSource.signUp(email: email, password: password, name: name),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repository.signUp(
        email: email,
        password: password,
        name: name,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'An account with this email already exists.');
      }, (_) => fail('Expected Left'));
    });
  });

  group('resetPassword', () {
    const email = 'test@optivus.com';

    test('returns Right(null) on success', () async {
      when(
        () => mockDataSource.resetPassword(email: email),
      ).thenAnswer((_) async {});

      final result = await repository.resetPassword(email: email);

      expect(result.isRight(), true);
    });
  });
}
