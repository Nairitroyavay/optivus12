import 'package:flutter_test/flutter_test.dart';

import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optivus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:optivus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:optivus/features/auth/domain/repositories/auth_repository.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/network/network_info.dart';

// ─── Mocks ─────────────────────────────────────────────────────
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    // default to online unless a test says otherwise
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    repository = AuthRepositoryImpl(mockDataSource, mockNetworkInfo);
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

    test('returns failure immediately when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.signIn(email: email, password: password);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'No internet connection. Please check your connection and try again.');
      }, (_) => fail('Expected Left'));
      verifyNever(() => mockDataSource.signIn(email: email, password: password));
    });

    test('times out when remote call takes too long', () async {
      // simulate a hang by returning a future that never completes
      when(
        () => mockDataSource.signIn(email: email, password: password),
      ).thenAnswer((_) => Future.delayed(const Duration(seconds: 60)));

      final result = await repository.signIn(email: email, password: password);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'Connection timed out. Please check your internet and try again.');
      }, (_) => fail('Expected Left'));
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

    test(
      'returns AuthSignUpNeedsVerification when user email is not verified',
      () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
        when(() => mockCredential.user).thenReturn(mockUser);
        when(
          () =>
              mockDataSource.signUp(email: email, password: password, name: name),
        ).thenAnswer((_) async => mockCredential);

        final result = await repository.signUp(
          email: email,
          password: password,
          name: name,
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (signUpResult) =>
              expect(signUpResult, isA<AuthSignUpNeedsVerification>()),
        );
      },
    );

    test('returns failure immediately when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.signUp(
          email: email, password: password, name: name);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'No internet connection. Please check your connection and try again.');
      }, (_) => fail('Expected Left'));
      verifyNever(
          () => mockDataSource.signUp(email: email, password: password, name: name));
    });

    test('signUp times out when datasource hangs', () async {
      when(
        () =>
            mockDataSource.signUp(email: email, password: password, name: name),
      ).thenAnswer((_) => Future.delayed(const Duration(seconds: 60)));

      final result = await repository.signUp(
          email: email, password: password, name: name);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'Connection timed out. Please check your internet and try again.');
      }, (_) => fail('Expected Left'));
    });

    test(
      'returns AuthSignUpConfirmed when user is already verified (e.g. SSO)',
      () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockCredential.user).thenReturn(mockUser);
        when(
          () =>
              mockDataSource.signUp(email: email, password: password, name: name),
        ).thenAnswer((_) async => mockCredential);

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
      },
    );

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

    test('fails immediately when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.resetPassword(email: email);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'No internet connection. Please check your connection and try again.');
      }, (_) => fail('Expected Left'));
      verifyNever(() => mockDataSource.resetPassword(email: email));
    });

    test('times out if datasource hangs', () async {
      when(
        () => mockDataSource.resetPassword(email: email),
      ).thenAnswer((_) => Future.delayed(const Duration(seconds: 60)));

      final result = await repository.resetPassword(email: email);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message,
            'Connection timed out. Please check your internet and try again.');
      }, (_) => fail('Expected Left'));
    });
  });
}
