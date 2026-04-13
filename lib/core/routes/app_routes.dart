import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/favourite_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/home_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/movie_details_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/search_screen.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String details = '/details';
  static const String favourites = '/favourites';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => singleton<MovieBloc>()..add(FetchPopularMovies()),
            child: const HomeScreen(),
          ),
        );
      case search:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => singleton<SearchCubit>(),
            child: const SearchScreen(),
          ),
        );
      case details:
        final params = settings.arguments as MovieDetailsParams;
        return MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(
            movieDetailsParams: MovieDetailsParams(params.movieId),
          ),
        );
      case favourites:
        return MaterialPageRoute(builder: (_) => const FavouriteScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
