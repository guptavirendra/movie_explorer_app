import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double rating;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required String backdropPath,
    required this.rating,
    required voteAverage,
    required voteCount,
  });

  @override
  List<Object?> get props => [id, title, overview, posterPath, releaseDate];
}
