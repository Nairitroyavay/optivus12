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
  Future<Either<Failure, DailySummary>> getDailySummary() async {
    try {
      final json = await remote.fetchDailySummary();
      final model = DailySummaryModel.fromJson(json);
      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get daily summary', e, stackTrace);
      return Left(ServerFailure());
    }
  }
}
