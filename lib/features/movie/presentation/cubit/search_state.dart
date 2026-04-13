import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Movie> movies;
  final bool hasReachedMax;
  final bool isLoadingMore;
  SearchLoaded({
    required this.movies,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  SearchLoaded copyWith({
    List<Movie>? movies,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return SearchLoaded(
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  final String message;
  SearchError({required this.message});
}
