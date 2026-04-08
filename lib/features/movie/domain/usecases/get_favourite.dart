import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movies.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class GetFavourite implements UseCase<List<Movie>, NoParams> {
  final MovieRepository repository;
  GetFavourite(this.repository);

  @override
  Future<List<Movie>> call(NoParams params) async {
    // Implementation for getting favorite movies
    return await repository.getFavoriteMovies();
  }
}
