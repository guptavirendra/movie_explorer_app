import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

class SearchMovies implements UseCase<List<Movie>, SearchParams> {
  final MovieRepository repository;

  SearchMovies(this.repository);

  @override
  Future<List<Movie>> call(SearchParams params) async {
    return repository.searchMovies(params.query, params.page);
  }
}
