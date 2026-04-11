abstract class FavouriteState {}

final class FavouriteInitial extends FavouriteState {}

final class FavouriteLoading extends FavouriteState {}

final class FavouriteLoaded extends FavouriteState {
  final List movies;
  FavouriteLoaded({required this.movies});
}

final class FavouriteEmpty extends FavouriteState {}

final class FavouriteError extends FavouriteState {
  final String message;
  FavouriteError({required this.message});
}
