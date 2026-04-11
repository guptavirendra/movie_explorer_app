import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMovies searchMovies;
  Timer? _debounce;

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
          final movies = await searchMovies(
            SearchParams(query: query, page: 1),
          );
          if (movies.isEmpty) {
            emit(SearchEmpty());
          } else {
            emit(SearchLoaded(movies: movies));
          }
        } catch (e) {
          emit(SearchError(message: e.toString()));
        }
      }
    });
  }
}
