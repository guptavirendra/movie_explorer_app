import 'package:dio/dio.dart';
import 'package:movie_explorer_app/core/constants/api_constants.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/core/network/dio_client.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/data/models/popular_movies_response_model.dart';

abstract class MovieRemoteDataSource {
  Future<PopularMoviesResponseModel> getPopularMovies(int page);
  Future<MovieModel> getMovieDetails(int id);
  Future<List<MovieModel>> searchMovies(String query, int page);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;
  MovieRemoteDataSourceImpl(this.dioClient);

  ServerException _mapDioException(DioException e) {
    final responseData = e.response?.data;
    final responseMessage = responseData is Map<String, dynamic>
        ? responseData['status_message'] as String?
        : null;
    final isNetworkIssue = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.unknown;

    return ServerException(
      message: e.error?.toString() ??
          responseMessage ??
          e.response?.statusMessage ??
          e.message ??
          'Server Error',
      statusCode: isNetworkIssue ? 0 : (e.response?.statusCode ?? 500),
    );
  }

  @override
  Future<PopularMoviesResponseModel> getPopularMovies(int page) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );

      return PopularMoviesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    try {
      final response =
          await dioClient.dio.get('${ApiConstants.movieDetails}/$id');
      return MovieModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, int page) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page},
      );
      final List<dynamic> results = response.data['results'];
      return results.map((movie) => MovieModel.fromJson(movie)).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }
}
