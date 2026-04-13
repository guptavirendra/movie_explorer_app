import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';

class PopularMoviesResponseModel {
  final List<MovieModel> movies;
  final int totalPages;

  const PopularMoviesResponseModel({
    required this.movies,
    required this.totalPages,
  });

  factory PopularMoviesResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> results = json['results'] ?? <dynamic>[];

    return PopularMoviesResponseModel(
      movies: results
          .map((movie) => MovieModel.fromJson(movie as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
