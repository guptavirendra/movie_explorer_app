import 'package:flutter/material.dart';
import 'package:movie_explorer_app/core/routes/app_routes.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!
        .pushNamed<T>(routeName, arguments: arguments);
  }

  void goToSearch() {
    pushNamed(AppRoutes.search);
  }

  void goToFavourites() {
    pushNamed(AppRoutes.favourites);
  }

  void goToMovieDetails(int movieId) {
    pushNamed(AppRoutes.details, arguments: MovieDetailsParams(movieId));
  }
}
