import 'package:equatable/equatable.dart';

import 'movie.dart';

class MovieResponse extends Equatable {
  final List<Movie> movies;
  final int totalPages;

  const MovieResponse({required this.movies, required this.totalPages});

  @override
  List<Object?> get props => [movies, totalPages];
}
