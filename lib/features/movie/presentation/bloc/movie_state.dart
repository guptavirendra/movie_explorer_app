import 'package:equatable/equatable.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const MovieLoaded({
    required this.movies,
    required this.hasReachedMax,
    this.isLoadingMore = false,
  });

  MovieLoaded copyWith({
    List<Movie>? movies,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MovieLoaded(
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [movies, hasReachedMax, isLoadingMore];
}

class MovieError extends MovieState {
  final String message;

  const MovieError({required this.message});

  @override
  List<Object?> get props => [message];
}
