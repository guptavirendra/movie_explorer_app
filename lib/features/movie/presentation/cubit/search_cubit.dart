import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMovies searchMovies;
  Timer? _debounce;
  int page = 1;
  bool isFetching = false;
  String currentQuery = "";
  List<Movie> movies = [];

  SearchCubit({required this.searchMovies}) : super(SearchInitial());

  void onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      } else {
        emit(SearchLoading());
        try {
          final result = await searchMovies(
            SearchParams(query: query, page: page),
          );
          movies = result;
          emit(SearchLoaded(movies: movies));
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
    if (isFetching || state is! SearchLoaded) return;

    isFetching = true;
    page++;

    try {
      final result = await searchMovies(
        SearchParams(query: currentQuery, page: page),
      );

      movies.addAll(result);

      emit(SearchLoaded(movies: movies));
    } catch (_) {}

    isFetching = false;
  }
}
