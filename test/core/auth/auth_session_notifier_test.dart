import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'package:optivus/core/auth/auth_state.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/core/auth/domain/profile_data.dart';
import 'package:optivus/core/auth/domain/profile_repository.dart';
import 'package:optivus/core/auth/data/profile_remote_datasource.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/services/analytics_service.dart';

// ─── Mocks ─────────────────────────────────────────────────────

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid-123';
}

// ─── Helpers ───────────────────────────────────────────────────

/// Pumps microtasks so all async hydration completes.
Future<void> pump() async {
  // Multiple microtask cycles to let all chained futures resolve.
  for (var i = 0; i < 10; i++) {
    await Future.microtask(() {});
  }
  // Plus a real delay for any timer-based operations.
  await Future.delayed(const Duration(milliseconds: 50));
}

ProviderContainer createContainer({
  required AsyncValue<User?> authValue,
  required MockProfileRepository profileRepo,
  required MockProfileRemoteDataSource dataSource,
  required MockAnalyticsService analytics,
}) {
  return ProviderContainer(
    overrides: [
      firebaseAuthStateProvider.overrideWithValue(authValue),
      profileRepositoryProvider.overrideWithValue(profileRepo),
      profileRemoteDataSourceProvider.overrideWithValue(dataSource),
      sharedPreferencesProvider.overrideWithValue(
        SharedPreferences.getInstance(),
      ),
      analyticsServiceProvider.overrideWithValue(analytics),
    ],
  );
}

// ─── Tests ─────────────────────────────────────────────────────

void main() {
  late MockProfileRepository mockProfileRepo;
  late MockProfileRemoteDataSource mockDataSource;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockDataSource = MockProfileRemoteDataSource();
    mockAnalytics = MockAnalyticsService();
    // Default: empty cache
    SharedPreferences.setMockInitialValues({});
  });

  group('build() synchronous returns', () {
    test('null user → AuthUnauthenticated', () {
      final container = createContainer(
        authValue: const AsyncData<User?>(null),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      expect(container.read(authSessionProvider), isA<AuthUnauthenticated>());
      container.dispose();
    });

    test('loading → AuthLoading', () {
      final container = createContainer(
        authValue: const AsyncLoading<User?>(),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      expect(container.read(authSessionProvider), isA<AuthLoading>());
      container.dispose();
    });

    test('error → AuthUnauthenticated', () {
      final container = createContainer(
        authValue: AsyncError<User?>(Exception('fail'), StackTrace.empty),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      expect(container.read(authSessionProvider), isA<AuthUnauthenticated>());
      container.dispose();
    });

    test('user present → AuthLoading (hydration kicked off)', () async {
      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: false)),
      );

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      // Synchronous return is AuthLoading
      expect(container.read(authSessionProvider), isA<AuthLoading>());
      // Let fire-and-forget hydration settle before disposing
      await pump();
      container.dispose();
    });
  });

  group('hydration (async)', () {
    test('new user → AuthAuthenticated(onboarding: false)', () async {
      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: false)),
      );

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      // Listen reactively for state transitions
      final states = <AuthState>[];
      container.listen(authSessionProvider, (_, next) {
        states.add(next);
      });

      // Trigger read + pump
      container.read(authSessionProvider);
      await pump();

      expect(states.last, isA<AuthAuthenticated>());
      expect((states.last as AuthAuthenticated).isOnboardingComplete, false);
      verify(() => mockProfileRepo.ensureProfile('test-uid-123')).called(1);
      container.dispose();
    });

    test('cached=true + network success → AuthAuthenticated(true)', () async {
      SharedPreferences.setMockInitialValues({
        'optivus_onboarding_complete': true,
      });

      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: true)),
      );

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      final states = <AuthState>[];
      container.listen(authSessionProvider, (_, next) {
        states.add(next);
      });

      container.read(authSessionProvider);
      await pump();

      // The final state should be onboarding=true
      final lastAuth = states.whereType<AuthAuthenticated>().last;
      expect(lastAuth.isOnboardingComplete, true);

      container.dispose();
    });

    test('no cache + network failure → AuthAuthenticated(false)', () async {
      when(
        () => mockProfileRepo.ensureProfile('test-uid-123'),
      ).thenAnswer((_) async => const Left(ServerFailure('Network error')));

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      final states = <AuthState>[];
      container.listen(authSessionProvider, (_, next) {
        states.add(next);
      });

      container.read(authSessionProvider);
      await pump();

      final lastAuth = states.whereType<AuthAuthenticated>().last;
      expect(lastAuth.isOnboardingComplete, false);

      container.dispose();
    });

    test('cached=true + network failure → stays true (trusts cache)', () async {
      SharedPreferences.setMockInitialValues({
        'optivus_onboarding_complete': true,
      });

      when(
        () => mockProfileRepo.ensureProfile('test-uid-123'),
      ).thenAnswer((_) async => const Left(ServerFailure('Network error')));

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      final states = <AuthState>[];
      container.listen(authSessionProvider, (_, next) {
        states.add(next);
      });

      container.read(authSessionProvider);
      await pump();

      final lastAuth = states.whereType<AuthAuthenticated>().last;
      expect(lastAuth.isOnboardingComplete, true);

      container.dispose();
    });
  });

  group('completeOnboarding()', () {
    test('success → state=true, cache=true, analytics fired', () async {
      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: false)),
      );
      when(
        () => mockProfileRepo.markOnboardingComplete('test-uid-123'),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockAnalytics.logOnboardingComplete(),
      ).thenAnswer((_) async {});

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      // Listen and wait for hydration
      final states = <AuthState>[];
      container.listen(authSessionProvider, (_, next) => states.add(next));
      container.read(authSessionProvider);
      await pump();

      // Now call completeOnboarding
      await container.read(authSessionProvider.notifier).completeOnboarding();
      await pump();

      final lastAuth = states.whereType<AuthAuthenticated>().last;
      expect(lastAuth.isOnboardingComplete, true);

      verify(
        () => mockProfileRepo.markOnboardingComplete('test-uid-123'),
      ).called(1);
      verify(() => mockAnalytics.logOnboardingComplete()).called(1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('optivus_onboarding_complete'), true);

      container.dispose();
    });

    test('failure → throws Exception', () async {
      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: false)),
      );
      when(
        () => mockProfileRepo.markOnboardingComplete('test-uid-123'),
      ).thenAnswer((_) async => const Left(ServerFailure('Write failed')));

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      container.listen(authSessionProvider, (prev, next) {});
      container.read(authSessionProvider);
      await pump();

      await expectLater(
        container.read(authSessionProvider.notifier).completeOnboarding(),
        throwsA(isA<Exception>()),
      );

      container.dispose();
    });
  });

  group('logout()', () {
    test('clears cache and calls datasource.signOut()', () async {
      SharedPreferences.setMockInitialValues({
        'optivus_onboarding_complete': true,
      });

      when(() => mockProfileRepo.ensureProfile('test-uid-123')).thenAnswer(
        (_) async => const Right(ProfileData(isOnboardingComplete: true)),
      );
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      final container = createContainer(
        authValue: AsyncData<User?>(MockUser()),
        profileRepo: mockProfileRepo,
        dataSource: mockDataSource,
        analytics: mockAnalytics,
      );

      container.listen(authSessionProvider, (prev, next) {});
      container.read(authSessionProvider);
      await pump();

      await container.read(authSessionProvider.notifier).logout();

      verify(() => mockDataSource.signOut()).called(1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('optivus_onboarding_complete'), isNull);

      container.dispose();
    });
  });
}
