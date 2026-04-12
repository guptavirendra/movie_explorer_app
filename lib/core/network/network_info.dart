import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();

    final hasNetwork = !connectivityResult.contains(ConnectivityResult.none);

    //if (!hasNetwork) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
