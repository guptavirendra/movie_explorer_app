import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';

abstract class MovieLocalDatasource {
  Future<void> toggleFavorite(MovieModel movie);
  Future<List<MovieModel>> getFavorites();
}

class MovieLocalDatasourceImpl implements MovieLocalDatasource {
  final Box box;
  MovieLocalDatasourceImpl(this.box);

  @override
  Future<void> toggleFavorite(MovieModel movie) async {
    if (box.containsKey(movie.id)) {
      await box.delete(movie.id);
    } else {
      await box.put(movie.id, movie);
    }
  }

  @override
  Future<List<MovieModel>> getFavorites() async {
    return box.values.cast<MovieModel>().toList();
  }
}
