import 'package:flutter_bloc/flutter_bloc.dart';
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

  bool isFavorite = false;

  Future<void> fetchMovieDetails(MovieDetailsParams params) async {
    emit(MovieDetailsLoading());

    try {
      final movie = await getMovieDetails(params);
      await _checkIfFavorite(movie); // ✅ correct

      emit(MovieDetailsLoaded(movie));
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }

  Future<void> toggleFav(Movie movie) async {
    print("Toggle called for: ${movie.title}");

    await toggleFavorite(movie);

    isFavorite = !isFavorite;

    print("isFavorite now: $isFavorite");

    emit(MovieDetailsLoaded(movie)); // 🔥 VERY IMPORTANT
  }

  Future<void> _checkIfFavorite(Movie movie) async {
    final favorites = await getFavorites(NoParams());

    isFavorite = favorites.any((m) => m.id == movie.id);
  }
}
