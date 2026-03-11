import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_info.dart';

/// Provides a concrete implementation of [NetworkInfo].
///
/// Currently uses the `internet_connection_checker` package under the hood,
/// but the public API is just a simple `isConnected` getter so tests can
/// easily substitute a fake.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
