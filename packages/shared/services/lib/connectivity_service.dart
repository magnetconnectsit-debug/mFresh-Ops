// region Imports
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// endregion

// region ConnectivityService
class ConnectivityService extends GetxService {
  // region Observables & State Variables
  final isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Connectivity _connectivity = Connectivity();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
  // endregion

  // region Helpers & Network Checks
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('ConnectivityService: Failed to check initial connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
    if (isConnected.value != hasConnection) {
      isConnected.value = hasConnection;
      debugPrint('ConnectivityService: Connection status changed -> isConnected: $hasConnection');
    }
  }
  // endregion
}
// endregion
