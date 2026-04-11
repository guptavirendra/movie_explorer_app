import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

class GetMovieDetails implements UseCase<Movie, MovieDetailsParams> {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  @override
  Future<Movie> call(MovieDetailsParams params) async {
    return await repository.getMovieDetails(params.movieId);
  }
}
