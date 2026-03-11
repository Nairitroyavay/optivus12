import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:optivus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:optivus/features/auth/domain/repositories/auth_repository.dart';
import 'package:optivus/core/network/network_providers.dart';

/// Composition root for the auth feature.
/// All wiring stays here — screens only see [AuthRepository].

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(dataSource, networkInfo);
});
