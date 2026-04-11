abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List movies;
  SearchLoaded({required this.movies});
}

class SearchError extends SearchState {
  final String message;
  SearchError({required this.message});
}
