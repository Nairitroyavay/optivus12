import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/features/feed/domain/entities/daily_summary.dart';
import 'package:optivus/features/feed/domain/repositories/feed_repository.dart';

class GetDailySummary {
  final FeedRepository repository;

  GetDailySummary(this.repository);

  Future<Either<Failure, DailySummary>> call(String uid) {
    return repository.getDailySummary(uid);
  }
}
