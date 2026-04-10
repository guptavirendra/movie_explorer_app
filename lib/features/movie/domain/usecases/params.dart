class PageParams {
  final int page;

  PageParams({required this.page});
}

class MovieDetailsParams {
  final int movieId;

  MovieDetailsParams(this.movieId);
}

class SearchMoviesParams {
  final String query;
  final int page;

  SearchMoviesParams(this.query, this.page);
}
