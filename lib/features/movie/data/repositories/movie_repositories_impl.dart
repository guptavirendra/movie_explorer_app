import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';

class MovieRepositoriesImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDatasource localDataSource;
  final NetworkInfo networkInfo;
  MovieRepositoriesImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  Never _throwFromServerException(ServerException e) {
    if (e.statusCode == 0) {
      throw NetworkFailure();
    }
    throw ServerFailure();
  }

  Never _throwCacheFailure() {
    throw CacheFailure();
  }

  @override
  Future<MovieResponse> getPopularMovies(int page) async {
    if (!await networkInfo.isConnected) {
      throw NetworkFailure();
    }
    try {
      final data = await remoteDataSource.getPopularMovies(page);
      final movies = data.movies.map((movie) => movie.toEntity()).toList();

      return MovieResponse(movies: movies, totalPages: data.totalPages);
    } on ServerException catch (_) {
      throw ServerFailure();
    }
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final result = await remoteDataSource.getMovieDetails(movieId);
      return result.toEntity();
    } on ServerException catch (e) {
      _throwFromServerException(e);
    }
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final model = MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      rating: movie.rating,
      releaseDate: movie.releaseDate,
    );
    try {
      await localDataSource.toggleFavorite(model);
    } catch (_) {
      _throwCacheFailure();
    }
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final favoriteMovies = await localDataSource.getFavorites();
      return favoriteMovies.map((movie) => movie.toEntity()).toList();
    } catch (_) {
      _throwCacheFailure();
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query, int page) async {
    try {
      final result = await remoteDataSource.searchMovies(query, page);
      return result.map((e) => e.toEntity()).toList();
    } on ServerException catch (e) {
      _throwFromServerException(e);
    }
  }
}
