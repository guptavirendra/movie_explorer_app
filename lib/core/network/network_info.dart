import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
