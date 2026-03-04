import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:optivus/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:optivus/features/feed/data/repositories/feed_repository_impl.dart';

import 'package:optivus/core/failures/failure.dart';

// ─── Mocks ─────────────────────────────────────────────────────
class MockFeedRemoteDataSource extends Mock implements FeedRemoteDataSource {}

void main() {
  late MockFeedRemoteDataSource mockDataSource;
  late FeedRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockFeedRemoteDataSource();
    repository = FeedRepositoryImpl(mockDataSource);
  });

  group('getDailySummary', () {
    const uid = 'test-user-123';

    test('returns DailySummary on success', () async {
      when(() => mockDataSource.fetchDailySummary(uid)).thenAnswer(
        (_) async => {
          'calories': 350,
          'minutes': 45,
          'insight': 'Great progress today!',
          'task_progress': 0.75,
          'tasks_completed': 3,
          'tasks_total': 4,
        },
      );

      final result = await repository.getDailySummary(uid);

      expect(result.isRight(), true);
      final summary = result.getOrElse(
        (_) => throw Exception('Expected Right'),
      );
      expect(summary.caloriesBurned, 350);
      expect(summary.activeMinutes, 45);
      expect(summary.insightMessage, 'Great progress today!');
      expect(summary.taskProgress, 0.75);
      expect(summary.tasksCompleted, 3);
      expect(summary.tasksTotal, 4);
      verify(() => mockDataSource.fetchDailySummary(uid)).called(1);
    });

    test('returns DailySummary with defaults for empty data', () async {
      when(() => mockDataSource.fetchDailySummary(uid)).thenAnswer(
        (_) async => {
          'calories': 0,
          'minutes': 0,
          'insight': 'No data recorded yet today.',
          'task_progress': 0.0,
          'tasks_completed': 0,
          'tasks_total': 0,
        },
      );

      final result = await repository.getDailySummary(uid);

      expect(result.isRight(), true);
      final summary = result.getOrElse(
        (_) => throw Exception('Expected Right'),
      );
      expect(summary.caloriesBurned, 0);
      expect(summary.insightMessage, 'No data recorded yet today.');
    });

    test('returns ServerFailure on FirebaseException', () async {
      when(() => mockDataSource.fetchDailySummary(uid)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'Offline',
          code: 'unavailable',
        ),
      );

      final result = await repository.getDailySummary(uid);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Failed to load your daily summary.');
      }, (_) => fail('Expected Left'));
    });

    test('returns ServerFailure on unexpected exception', () async {
      when(
        () => mockDataSource.fetchDailySummary(uid),
      ).thenThrow(Exception('Something went wrong'));

      final result = await repository.getDailySummary(uid);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
