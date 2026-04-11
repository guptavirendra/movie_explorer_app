abstract class FavouritesState {}

final class FavouritesInitial extends FavouritesState {}

final class FavouritesLoading extends FavouritesState {}

final class FavouritesLoaded extends FavouritesState {
  final List movies;
  FavouritesLoaded({required this.movies});
}

final class FavouritesEmpty extends FavouritesState {}

final class FavouritesError extends FavouritesState {
  final String message;
  FavouritesError({required this.message});
}
