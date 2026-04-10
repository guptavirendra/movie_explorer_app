import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies(int page);
  Future<List<Movie>> searchMovies(String query, int page);
  Future<Movie> getMovieDetails(int movieId);
  Future<void> toggleFavorite(Movie movie);
  Future<List<Movie>> getFavoriteMovies();
}
