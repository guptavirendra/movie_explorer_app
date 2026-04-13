import 'package:equatable/equatable.dart';

class PageParams extends Equatable {
  final int page;

  const PageParams({required this.page});

  @override
  List<Object?> get props => [page];
}

class MovieDetailsParams extends Equatable {
  final int movieId;

  const MovieDetailsParams(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class SearchParams extends Equatable {
  final String query;
  final int page;

  const SearchParams({required this.query, required this.page});

  @override
  List<Object?> get props => [query, page];
}
