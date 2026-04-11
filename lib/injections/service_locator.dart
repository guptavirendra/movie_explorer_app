import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/repositories/movie_repositories_impl.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_popular_movies.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_cubit.dart';

final singleton = GetIt.instance;

Future<void> init() async {
  // ----------------------------
  // External
  // ----------------------------
  singleton.registerLazySingleton(() => Dio());
  singleton.registerLazySingleton(() => Connectivity());

  // ----------------------------
  // Core
  // ----------------------------
  singleton.registerLazySingleton(() => DioClient(singleton()));
  singleton.registerLazySingleton(() => NetworkInfo(singleton()));

  // ----------------------------
  // Hive (MUST come before local datasource)
  // ----------------------------
  final box = await Hive.openBox('favorites');
  singleton.registerLazySingleton(() => box);

  // ----------------------------
  // Data Sources
  // ----------------------------
  singleton.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(singleton()),
  );

  singleton.registerLazySingleton<MovieLocalDatasource>(
    () => MovieLocalDatasourceImpl(singleton()),
  );

  // ----------------------------
  // Repository
  // ----------------------------
  singleton.registerLazySingleton<MovieRepository>(
    () => MovieRepositoriesImpl(singleton(), singleton()),
  );

  // ----------------------------
  // UseCases
  // ----------------------------
  singleton.registerLazySingleton(() => GetPopularMovies(singleton()));
  singleton.registerLazySingleton(() => GetMovieDetails(singleton()));
  singleton.registerLazySingleton(() => SearchMovies(singleton()));
  // singleton.registerLazySingleton(() => ToggleFavorite(singleton()));
  // singleton.registerLazySingleton(() => GetFavorites(singleton()));

  // ----------------------------
  // Bloc (Factory ❗)
  // ----------------------------
  singleton.registerFactory(() => MovieBloc(singleton()));

  singleton.registerFactory(() => MovieDetailsCubit(singleton()));
}
