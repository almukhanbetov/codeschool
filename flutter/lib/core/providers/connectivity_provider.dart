import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the device has *some* network interface up. This is a
/// necessary-but-not-sufficient signal (a captive portal can be "connected"
/// with no real internet) — used only to drive the offline banner and to
/// gate destructive retries, never as the sole basis for a security
/// decision.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});
