import 'package:hive/hive.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

part 'movie_model.g.dart'; // 🔥 IMPORTANT

@HiveType(typeId: 0)
class MovieModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String overview;

  @HiveField(3)
  final String posterPath;

  @HiveField(4)
  final String backdropPath;

  @HiveField(5)
  final double? rating;

  @HiveField(6)
  final String releaseDate;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.releaseDate,
    required double voteAverage,
    required int voteCount,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: (json['vote_count'] ?? 0),
    );
  }
  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      rating: rating ?? 0.0,
      releaseDate: releaseDate,
      voteAverage: rating ?? 0.0,
      voteCount: (rating ?? 0.0).toInt(),
    );
  }
}
