import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  get props => [];
}

class FetchPopularMovies extends MovieEvent {}

class LoadMoreMovies extends MovieEvent {}

class RefreshMovies extends MovieEvent {}
