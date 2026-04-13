import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

import '../../domain/usecases/get_popular_movies.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMovies getPopularMovies;
  int totalPages = 1;

  PageParams page = PageParams(page: 1);

  MovieBloc(this.getPopularMovies) : super(MovieInitial()) {
    on<FetchPopularMovies>(_onFetch);
    on<LoadMoreMovies>(_onLoadMore);
    on<RefreshMovies>(_onRefresh);
  }

  Future<void> _onFetch(
    FetchPopularMovies event,
    Emitter<MovieState> emit,
  ) async {
    page = PageParams(page: 1);
    emit(MovieLoading());

    try {
      final response = await getPopularMovies(page);

      totalPages = response.totalPages;

      emit(
        MovieLoaded(
          movies: response.movies,
          hasReachedMax: page.page >= totalPages,
        ),
      );
    } on NetworkFailure {
      emit(MovieError(message: 'Please check your connection and try again.'));
    } on ServerFailure catch (e) {
      emit(MovieError(message: 'Server error: ${e.message}'));
    } catch (e) {
      emit(MovieError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state is! MovieLoaded) return;

    final currentState = state as MovieLoaded;

    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      page = PageParams(page: page.page + 1);

      final response = await getPopularMovies(page);

      emit(
        currentState.copyWith(
          movies: [...currentState.movies, ...response.movies],
          hasReachedMax: page.page >= totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(RefreshMovies event, Emitter<MovieState> emit) async {
    try {
      page = PageParams(page: 1);

      final response = await getPopularMovies(page);

      totalPages = response.totalPages;

      emit(
        MovieLoaded(
          movies: response.movies,
          hasReachedMax: page.page >= totalPages,
        ),
      );
    } catch (e) {
      emit(MovieError(message: 'Failed to refresh movies'));
    }
  }
}
