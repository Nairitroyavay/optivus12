import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/logger/app_logger.dart';
import 'package:optivus/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:optivus/features/feed/data/models/daily_summary_model.dart';
import 'package:optivus/features/feed/domain/entities/daily_summary.dart';
import 'package:optivus/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remote;

  FeedRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, DailySummary>> getDailySummary(String uid) async {
    try {
      final json = await remote.fetchDailySummary(uid);
      final model = DailySummaryModel.fromJson(json);
      return Right(model.toEntity());
    } on FirebaseException catch (e) {
      AppLogger.error('Firestore query failed for daily summary', e);
      return Left(ServerFailure('Failed to load your daily summary.'));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get daily summary', e, stackTrace);
      return Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
