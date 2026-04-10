import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

import '../../domain/usecases/get_popular_movies.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMovies getPopularMovies;

  PageParams page = PageParams(page: 1);
  bool isFetching = false;

  MovieBloc(this.getPopularMovies) : super(MovieInitial()) {
    on<FetchPopularMovies>(_onFetch);
    on<LoadMoreMovies>(_onLoadMore);
    on<RefreshMovies>(_onRefresh);
  }

  Future<void> _onFetch(
    FetchPopularMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());

    try {
      final movies = await getPopularMovies(page);
      emit(MovieLoaded(movies: movies, hasReachedMax: false));
    } catch (e) {
      emit(MovieError(e.toString(), message: 'Failed to fetch movies'));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (isFetching || state is! MovieLoaded) return;

    isFetching = true;
    page = PageParams(page: page.page + 1);

    final currentState = state as MovieLoaded;

    try {
      final newMovies = await getPopularMovies(page);

      emit(
        MovieLoaded(
          movies: [...currentState.movies, ...newMovies],
          hasReachedMax: newMovies.isEmpty,
        ),
      );
    } catch (_) {}

    isFetching = false;
  }

  Future<void> _onRefresh(RefreshMovies event, Emitter<MovieState> emit) async {
    page = PageParams(page: 1);

    try {
      final movies = await getPopularMovies(page);
      emit(MovieLoaded(movies: movies, hasReachedMax: false));
    } catch (e) {
      emit(MovieError(e.toString(), message: 'Failed to refresh movies'));
    }
  }
}
