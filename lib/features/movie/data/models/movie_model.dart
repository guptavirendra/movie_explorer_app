import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'],
    );
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      //backdropPath: backdropPath,
      //voteAverage: voteAverage,
      //voteCount: voteCount,
      releaseDate: releaseDate,
    );
  }
}
