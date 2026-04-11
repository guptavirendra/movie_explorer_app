import 'movie.dart';

class MovieResponse {
  final List<Movie> movies;
  final int totalPages;

  MovieResponse({required this.movies, required this.totalPages});
}
