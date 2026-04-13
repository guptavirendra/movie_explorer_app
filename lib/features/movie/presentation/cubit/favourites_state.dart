import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class FavouritesState {}

final class FavouritesInitial extends FavouritesState {}

final class FavouritesLoading extends FavouritesState {}

final class FavouritesLoaded extends FavouritesState {
  final List<Movie> movies;
  FavouritesLoaded({required this.movies});
}

final class FavouritesEmpty extends FavouritesState {}

final class FavouritesError extends FavouritesState {
  final String message;
  FavouritesError({required this.message});
}
