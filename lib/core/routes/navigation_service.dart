import 'package:go_router/go_router.dart';
import 'package:movie_explorer_app/core/routes/app_routes.dart';

class NavigationService {
  late GoRouter _router;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void goToSearch() {
    _router.push(AppRoutes.search);
  }

  void goToFavourites() {
    _router.push(AppRoutes.favourites);
  }

  void goToMovieDetails(int movieId) {
    _router.push(AppRoutes.movieDetailsPath(movieId));
  }
}
