
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';

final singleton = GetIt.instance;

Future<void> init() async {
  // Register other dependencies here
  //Dio
  singleton.registerLazySingleton(() => Dio());
  singleton.registerLazySingleton(() => DioClient(singleton()));

// Connectivity
  singleton.registerLazySingleton(() => Connectivity());
  singleton.registerLazySingleton(() => NetworkInfo(singleton()));
  
    
  
}