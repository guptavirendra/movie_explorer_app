import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMovies searchMovies;
  Timer? _debounce;
  int page = 1;
  String currentQuery = "";

  SearchCubit({required this.searchMovies}) : super(SearchInitial());

  void onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      } else {
        currentQuery = query;
        page = 1;
        emit(SearchLoading());
        try {
          final result = await searchMovies(
            SearchParams(query: query, page: page),
          );
          emit(SearchLoaded(movies: result));
        } catch (e) {
          if (e is Failure) {
            emit(SearchError(message: e.message));
          } else {
            emit(SearchError(message: e.toString()));
          }
        }
      }
    });
  }

  Future<void> loadMore() async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;

    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      page++;

      final newMovies = await searchMovies(
        SearchParams(query: currentQuery, page: page),
      );

      emit(
        currentState.copyWith(
          movies: [...currentState.movies, ...newMovies],
          hasReachedMax: newMovies.isEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> retry() async {
    if (currentQuery.isEmpty) return;

    page = 1;

    emit(SearchLoading());

    try {
      final movies = await searchMovies(
        SearchParams(query: currentQuery, page: page),
      );

      if (movies.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(movies: movies, hasReachedMax: false));
      }
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }
}
