import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_explorer_app/config/env.dart';
import 'package:movie_explorer_app/core/network/interceptors.dart';

class DioClient {
  final Dio dio;
  DioClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
    dio.interceptors.add(ApiKeyInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));
  }
}
