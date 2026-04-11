import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_favourite.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  GetFavourite getFavorites;
  ToggleFavourite toggleFavorite;
  FavouritesCubit({required this.getFavorites, required this.toggleFavorite})
    : super(FavouritesInitial());

  Future<void> loadFavorites() async {
    emit(FavouritesLoading());
    try {
      final movies = await getFavorites(NoParams());
      if (movies.isEmpty) {
        emit(FavouritesEmpty());
      } else {
        emit(FavouritesLoaded(movies: movies));
      }
    } catch (e) {
      emit(FavouritesError(message: e.toString()));
    }
  }

  Future<void> removeFavorite(Movie movie) async {
    await toggleFavorite(movie);
    await loadFavorites(); // refresh list
  }
}
