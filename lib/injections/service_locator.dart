import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_explorer_app/core/cache/hive_service.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/core/routes/navigation_service.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/repositories/movie_repositories_impl.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_favourite.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_popular_movies.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_cubit.dart';

final singleton = GetIt.instance;

Future<void> init() async {
  // Core
  final hiveService = HiveService();
  await hiveService.init();

  singleton.registerLazySingleton<HiveService>(() => hiveService);
  singleton.registerLazySingleton<NavigationService>(() => NavigationService());

  // External dependencies
  singleton.registerLazySingleton(() => Dio());
  singleton.registerLazySingleton(() => Connectivity());

  // Networking
  singleton.registerLazySingleton(() => DioClient(singleton<Dio>()));
  singleton.registerLazySingleton(() => NetworkInfo(singleton<Connectivity>()));

  // Data sources
  singleton.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(singleton<DioClient>()),
  );

  singleton.registerLazySingleton<MovieLocalDatasource>(
    () => MovieLocalDatasourceImpl(singleton<HiveService>()),
  );

  // Repository
  singleton.registerLazySingleton<MovieRepository>(
    () => MovieRepositoriesImpl(
      singleton<MovieRemoteDataSource>(),
      singleton<MovieLocalDatasource>(),
      singleton<NetworkInfo>(),
    ),
  );

  // Use cases
  singleton.registerLazySingleton(() => GetPopularMovies(singleton()));
  singleton.registerLazySingleton(() => GetMovieDetails(singleton()));
  singleton.registerLazySingleton(() => SearchMovies(singleton()));
  singleton.registerLazySingleton(() => ToggleFavourite(singleton()));
  singleton.registerLazySingleton(() => GetFavourite(singleton()));

  // Blocs / Cubits
  singleton.registerFactory(() => MovieBloc(singleton()));

  singleton.registerFactory(
    () => MovieDetailsCubit(
      singleton<GetMovieDetails>(),
      singleton<ToggleFavourite>(),
      singleton<GetFavourite>(),
    ),
  );

  singleton.registerFactory(
    () => FavouritesCubit(
      getFavorites: singleton<GetFavourite>(),
      toggleFavorite: singleton<ToggleFavourite>(),
    ),
  );

  singleton.registerFactory(
    () => SearchCubit(searchMovies: singleton<SearchMovies>()),
  );
}
