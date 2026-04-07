import 'package:dio/dio.dart';
import 'package:movie_explorer_app/config/env.dart';
import 'package:movie_explorer_app/core/network/interceptors.dart';

class DioClient {
  final Dio dio;
  DioClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.interceptors.add(ApiKeyInterceptor());
  }
}
