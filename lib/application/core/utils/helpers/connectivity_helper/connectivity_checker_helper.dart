import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCheckerHelper {
  static Stream<List<ConnectivityResult>> listenToConnectivityChanged() {
    return Connectivity().onConnectivityChanged;
  }
}