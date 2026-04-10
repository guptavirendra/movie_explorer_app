abstract class MovieState {
  get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List movies;
  final bool hasReachedMax;

  MovieLoaded({required this.movies, required this.hasReachedMax});

  @override
  get props => [movies, hasReachedMax];
}

class MovieError extends MovieState {
  final String message;

  MovieError(String string, {required this.message});

  @override
  get props => [message];
}
