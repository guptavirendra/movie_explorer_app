import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetails getMovieDetails;
  final ToggleFavourite toggleFavorite;

  MovieDetailsCubit(this.getMovieDetails, this.toggleFavorite)
    : super(MovieDetailsInitial());

  bool isFavorite = false;

  Future<void> fetchMovieDetails(MovieDetailsParams params) async {
    emit(MovieDetailsLoading());

    try {
      final movie = await getMovieDetails(params);
      emit(MovieDetailsLoaded(movie));
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }

  Future<void> toggleFavoriteStatus(Movie movie) async {
    try {
      await toggleFavorite(movie);
      isFavorite = !isFavorite;
      if (state is MovieDetailsLoaded) {
        emit(MovieDetailsLoaded(movie)); // refresh UI
      }
      // Optionally, you can emit a new state here to reflect the change in favorite status
    } catch (e) {
      // Handle error if needed
    }
  }
}
