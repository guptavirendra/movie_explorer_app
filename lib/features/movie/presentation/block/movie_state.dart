import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class MovieState {
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final bool hasReachedMax;

  MovieLoaded({required this.movies, required this.hasReachedMax});

  @override
  List<Object?> get props => [movies, hasReachedMax];
}

class MovieError extends MovieState {
  final String message;

  MovieError({required this.message});

  @override
  List<Object?> get props => [message];
}
