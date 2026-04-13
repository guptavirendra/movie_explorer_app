import 'package:equatable/equatable.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class FavouritesState extends Equatable {
  const FavouritesState();

  @override
  List<Object?> get props => [];
}

final class FavouritesInitial extends FavouritesState {}

final class FavouritesLoading extends FavouritesState {}

final class FavouritesLoaded extends FavouritesState {
  final List<Movie> movies;
  const FavouritesLoaded({required this.movies});

  @override
  List<Object?> get props => [movies];
}

final class FavouritesEmpty extends FavouritesState {}

final class FavouritesError extends FavouritesState {
  final String message;
  const FavouritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
