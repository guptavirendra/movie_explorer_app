import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class ToggleFavourite implements UseCase<void, Movie> {
  final MovieRepository repository;
  ToggleFavourite(this.repository);
  @override
  Future<void> call(Movie movie) async {
    return repository.toggleFavorite(movie);
  }
}
