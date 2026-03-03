import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/features/feed/domain/entities/daily_summary.dart';

abstract class FeedRepository {
  Future<Either<Failure, DailySummary>> getDailySummary(String uid);
}
