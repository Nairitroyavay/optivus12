/// Contract for checking network connectivity.
/// Later, we can implement this using packages like internet_connection_checker.
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker _checker;

  NetworkInfoImpl([InternetConnectionChecker? checker])
      : _checker = checker ?? InternetConnectionChecker();

  @override
  Future<bool> get isConnected => _checker.hasConnection;
}
