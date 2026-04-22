import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  void _init() {
    _checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Consider connected if there's any connection (wifi, mobile, ethernet, etc.)
    _isConnected = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }

  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return _isConnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
