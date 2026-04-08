import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movies.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class GetMovieDetails implements UseCase<Movie, int> {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  @override
  Future<Movie> call(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}