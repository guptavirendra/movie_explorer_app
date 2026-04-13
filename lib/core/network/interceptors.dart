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
      handler.next(err);
    }
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
      final responseData = response.data;
      final errorMessage = responseData is Map<String, dynamic>
          ? (responseData['status_message'] ?? 'Unknown error') as String
          : 'Unknown error';
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: errorMessage,
        ),
      );
      return;
    } else if (statusCode >= 500) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server error, please try again later.',
        ),
      );
      return;
    }
    handler.next(response);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // ❌ Do not retry for these
    if (_shouldNotRetry(err)) {
      return handler.next(err);
    }

    int retryCount = requestOptions.extra['retryCount'] ?? 0;

    if (retryCount < maxRetries) {
      retryCount++;

      requestOptions.extra['retryCount'] = retryCount;

      // exponential backoff
      await Future.delayed(Duration(seconds: 1 << retryCount));

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(e as DioException);
      }
    }

    return handler.next(err);
  }

  bool _shouldNotRetry(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;

    // ❌ don't retry client errors
    if (statusCode >= 400 && statusCode < 500) return true;

    // ❌ don't retry cancel
    if (err.type == DioExceptionType.cancel) return true;

    return false;
  }
}
