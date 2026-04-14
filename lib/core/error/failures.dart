abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure({String? message})
      : super(message ??
            "An error occurred while fetching data from the server.");
}

class CacheFailure extends Failure {
  CacheFailure()
      : super("An error occurred while fetching data from the cache.");
}

class NetworkFailure extends Failure {
  NetworkFailure()
      : super("An error occurred while fetching data from the network.");
}

class ServerException implements Exception {
  final String message;
  final int statusCode;

  ServerException({required this.message, required this.statusCode});
}
