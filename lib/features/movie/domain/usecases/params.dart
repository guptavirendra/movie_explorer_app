class PageParams {
  final int page;

  PageParams({required this.page});
}

class MovieDetailsParams {
  final int movieId;

  MovieDetailsParams(this.movieId);
}

class SearchParams {
  final String query;
  final int page;

  SearchParams({required this.query, required this.page});
}
