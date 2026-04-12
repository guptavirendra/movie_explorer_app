import 'package:dio/dio.dart';
import 'package:movie_explorer_app/config/env.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = Env.apiKey;
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timed out. Please check your internet connection.',
        ),
      );
    } else {
      handler.next(err); // Pass other errors to the next interceptor
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return handler.next(response);
    } else if (statusCode >= 400 && statusCode < 500) {
      // You can customize this error handling as needed
      final errorMessage = response.data['status_message'] ?? 'Unknown error';
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: errorMessage,
        ),
      );
      return; // Exit early since we're rejecting the response
    } else if (statusCode >= 500) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server error, please try again later.',
        ),
      );
      return; // Exit early since we're rejecting the response
    }
    super.onResponse(response, handler);
  }
}
