import 'package:movie_explorer_app/core/constants/api_constants.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies(int page);
  Future<MovieModel> getMovieDetails(int id);
  Future<List<MovieModel>> searchMovies(String query);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;
  MovieRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> getPopularMovies(int page) async {
    final response = await dioClient.dio.get(
      ApiConstants.popularMovies,
      queryParameters: {'page': page},
    );
    final List results = response.data['results'];
    return results.map((movie) => MovieModel.fromJson(movie)).toList();
  }

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    final response = await dioClient.dio.get(
      '${ApiConstants.movieDetails}/$id',
    );
    return MovieModel.fromJson(response.data);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await dioClient.dio.get(
      ApiConstants.searchMovies,
      queryParameters: {'query': query},
    );
    final List results = response.data['results'];
    return results.map((movie) => MovieModel.fromJson(movie)).toList();
  }
}
