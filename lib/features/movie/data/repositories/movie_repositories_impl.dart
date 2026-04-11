import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class MovieRepositoriesImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDatasource localDataSource;
  MovieRepositoriesImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<MovieResponse> getPopularMovies(int page) async {
    final data = await remoteDataSource.getPopularMovies(page);

    final movies = (data['results'] as List)
        .map((e) => MovieModel.fromJson(e).toEntity())
        .toList();

    return MovieResponse(movies: movies, totalPages: data['totalPages']);
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    final result = await remoteDataSource.getMovieDetails(movieId);
    return result.toEntity();
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final model = MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.posterPath,
      //rating: movie.rating,
      voteAverage: 1.0, // Placeholder, replace with actual rating if available
      releaseDate: movie.releaseDate,
      voteCount: 1, rating: 1.0,
    );

    await localDataSource.toggleFavorite(model);
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    final favoriteMovies = await localDataSource.getFavorites();
    return favoriteMovies.map((movie) => movie.toEntity()).toList();
  }

  @override
  Future<List<Movie>> searchMovies(String query, int page) async {
    final result = await remoteDataSource.searchMovies(query, page);
    return result.map((e) => e.toEntity()).toList();
  }
}
