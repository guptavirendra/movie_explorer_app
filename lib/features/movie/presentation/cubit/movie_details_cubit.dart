import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_favourite.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetails getMovieDetails;
  final ToggleFavourite toggleFavorite;
  final GetFavourite getFavorites;

  MovieDetailsCubit(
    this.getMovieDetails,
    this.toggleFavorite,
    this.getFavorites,
  ) : super(MovieDetailsInitial());

  Future<void> fetchMovieDetails(MovieDetailsParams params) async {
    emit(MovieDetailsLoading());

    try {
      final movie = await getMovieDetails(params);
      final isFavorite = await _checkIfFavorite(movie);

      emit(MovieDetailsLoaded(movie, isFavorite: isFavorite));
    } catch (e) {
      if (e is Failure) {
        emit(MovieDetailsError(e.message));
      } else {
        emit(MovieDetailsError(e.toString()));
      }
    }
  }

  Future<void> toggleFav(Movie movie) async {
    await toggleFavorite(movie);
    final currentState = state;
    final nextIsFavorite =
        currentState is MovieDetailsLoaded ? !currentState.isFavorite : false;

    emit(MovieDetailsLoaded(movie, isFavorite: nextIsFavorite));
  }

  Future<bool> _checkIfFavorite(Movie movie) async {
    final favorites = await getFavorites(NoParams());

    return favorites.any((m) => m.id == movie.id);
  }
}
