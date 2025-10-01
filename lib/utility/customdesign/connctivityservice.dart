import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    // Check initial connectivity
    initConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected =
          result.contains(ConnectivityResult.none) ? false : true;
      log('Connectivity changed: $isConnected');
      if (!_connectionController.isClosed) {
        _connectionController.add(isConnected);
      }
    });
  }

  Future<void> initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      bool isConnected =
          result.contains(ConnectivityResult.none) ? false : true;
      log('Initial connectivity: $isConnected');
      if (!_connectionController.isClosed) {
        _connectionController.add(isConnected);
      }
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
    }
  }

  Future<bool> checkConnectivity({int retries = 2, int delayMs = 200}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        await Future.delayed(Duration(milliseconds: delayMs));
        final result = await _connectivity.checkConnectivity();
        bool isConnected = !result.contains(ConnectivityResult.none);
        log('Check connectivity attempt ${i + 1}: $isConnected');
        if (isConnected) return true;
      } on PlatformException catch (e) {
        log('Couldn\'t check connectivity status', error: e);
      }
      if (i < retries) await Future.delayed(Duration(milliseconds: delayMs));
    }
    return false;
  }

  Stream<bool> get connectionStatus => _connectionController.stream;

  void dispose() {
    _connectionController.close();
  }
}
