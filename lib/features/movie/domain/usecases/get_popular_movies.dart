import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movies.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class GetPopularMovies implements UseCase<List<Movie>, int> {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  @override
  Future<List<Movie>> call(int page) async {
    return await repository.getPopularMovies(page);
  }
}