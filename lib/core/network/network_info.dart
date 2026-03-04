/// Contract for checking network connectivity.
/// Later, we can implement this using packages like internet_connection_checker.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true); // Mocked to always true for now
}
