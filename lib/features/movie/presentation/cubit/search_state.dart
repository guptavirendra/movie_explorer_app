import 'package:equatable/equatable.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Movie> movies;
  final bool hasReachedMax;
  final bool isLoadingMore;
  const SearchLoaded({
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

  @override
  List<Object?> get props => [movies, hasReachedMax, isLoadingMore];
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
