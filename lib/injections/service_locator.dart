import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/repositories/movie_repositories_impl.dart';

final singleton = GetIt.instance;

Future<void> init() async {
  // Register other dependencies here
  //Dio
  singleton.registerLazySingleton(() => Dio());
  singleton.registerLazySingleton(() => DioClient(singleton()));

  // Connectivity
  singleton.registerLazySingleton(() => Connectivity());
  singleton.registerLazySingleton(() => NetworkInfo(singleton()));

  // Movie Data Sources and Repository
  singleton.registerLazySingleton(() => MovieRemoteDataSourceImpl(singleton()));
  singleton.registerLazySingleton(() => MovieLocalDatasourceImpl(singleton()));
  singleton.registerLazySingleton(
    () => MovieRepositoriesImpl(singleton(), singleton()),
  );
  // Hive Box
  final box = await Hive.openBox('favorites');
  singleton.registerLazySingleton(() => box);
}
