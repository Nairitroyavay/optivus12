import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:optivus/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:optivus/features/feed/domain/entities/daily_summary.dart';
import 'package:optivus/features/feed/domain/repositories/feed_repository.dart';
import 'package:optivus/features/feed/domain/usecases/get_daily_summary.dart';

// --- Data Source ---
final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSource();
});

// --- Repository ---
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final remote = ref.watch(feedRemoteDataSourceProvider);
  return FeedRepositoryImpl(remote);
});

// --- Use Case ---
final getDailySummaryProvider = Provider<GetDailySummary>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return GetDailySummary(repo);
});

// --- Feature State ---
final dailySummaryProvider = FutureProvider<Either<Failure, DailySummary>>((
  ref,
) async {
  final usecase = ref.watch(getDailySummaryProvider);
  return usecase();
});
