// In a global service or main.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'connectivity_checker_helper.dart';

class ConnectivityService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  StreamSubscription? _connectivitySubscription;
  bool _isDisconnected = false;

  ConnectivityService(this.scaffoldMessengerKey) {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySubscription =
        ConnectivityCheckerHelper.listenToConnectivityChanged().listen((
          connectivityResult,
        ) {
          if (connectivityResult.first == ConnectivityResult.none) {
            _isDisconnected = true;
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Please check your Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (_isDisconnected) {
            _isDisconnected = false;
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Connection restored',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
