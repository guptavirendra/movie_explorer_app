import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_explorer_app/core/routes/navigation_service.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/favourite_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/home_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/movie_details_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/search_screen.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String details = '/details/:movieId';
  static const String favourites = '/favourites';

  static String movieDetailsPath(int movieId) => '/details/$movieId';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: home,
      routes: [
        GoRoute(
          path: home,
          builder: (context, state) => BlocProvider(
            create: (_) => singleton<MovieBloc>()..add(FetchPopularMovies()),
            child: HomeScreen(
              navigationService: singleton<NavigationService>(),
            ),
          ),
        ),
        GoRoute(
          path: search,
          builder: (context, state) => BlocProvider(
            create: (_) => singleton<SearchCubit>(),
            child: SearchScreen(
              navigationService: singleton<NavigationService>(),
            ),
          ),
        ),
        GoRoute(
          path: details,
          builder: (context, state) {
            final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
            if (movieId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid movie id')),
              );
            }
            final params = MovieDetailsParams(movieId);
            return BlocProvider(
              create: (_) =>
                  singleton<MovieDetailsCubit>()..fetchMovieDetails(params),
              child: const MovieDetailsScreen(),
            );
          },
        ),
        GoRoute(
          path: favourites,
          builder: (context, state) => BlocProvider(
            create: (_) => singleton<FavouritesCubit>()..loadFavorites(),
            child: const FavouriteScreen(),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text(state.error?.toString() ?? 'Route not found')),
      ),
    );
  }
}
