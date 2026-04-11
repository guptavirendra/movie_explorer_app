import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetails getMovieDetails;
  MovieDetailsCubit(this.getMovieDetails) : super(MovieDetailsInitial());
  Future<void> fetchMovieDetails(MovieDetailsParams params) async {
    emit(MovieDetailsLoading());

    try {
      final movie = await getMovieDetails(params);
      emit(MovieDetailsLoaded(movie));
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }
}
