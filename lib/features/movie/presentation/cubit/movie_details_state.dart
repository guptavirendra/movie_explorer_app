import 'package:equatable/equatable.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final Movie movie;
  final bool isFavorite;

  const MovieDetailsLoaded(this.movie, {required this.isFavorite});

  @override
  List<Object?> get props => [movie, isFavorite];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;
  const MovieDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
