import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/data/repositories/movie_repositories_impl.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';

import 'mocks.dart';

void main() {
  late MovieRepositoriesImpl repository;
  late MockRemoteDatasource mockRemoteDataSource;
  late MockLocalDatasource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDatasource();
    mockLocalDataSource = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();

    repository = MovieRepositoriesImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
    );
  });

  final tMovieModel = MovieModel(
    id: 1,
    title: "Test",
    overview: "Overview",
    posterPath: "/test.jpg",
    rating: 8.5,
    releaseDate: "2024-01-01",
  );
  final tMovie = tMovieModel.toEntity();

  // =========================
  // 🔥 TEST: getPopularMovies SUCCESS
  // =========================

  test('should return movies when network is connected', () async {
    // arrange
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    when(() => mockRemoteDataSource.getPopularMovies(1)).thenAnswer(
      (_) async => {
        "results": [
          {
            "id": tMovieModel.id,
            "title": tMovieModel.title,
            "overview": tMovieModel.overview,
            "poster_path": tMovieModel.posterPath,
            "backdrop_path": tMovieModel.backdropPath,
            "vote_average": tMovieModel.rating,
            "release_date": tMovieModel.releaseDate,
          },
        ],
        "totalPages": 1,
      },
    );

    // act
    final result = await repository.getPopularMovies(1);

    // assert
    expect(result, isA<MovieResponse>());
    expect(result.movies.first.id, tMovie.id);

    verify(() => mockRemoteDataSource.getPopularMovies(1)).called(1);
  });

  // ✅ This test ensures that the MovieRepositoriesImpl can be instantiated without errors.
  test('MovieRepositoriesImpl can be instantiated', () {
    final repository = MovieRepositoriesImpl(
      MockRemoteDatasource(),
      MockLocalDatasource(),
      MockNetworkInfo(),
    );

    expect(repository, isA<MovieRepositoriesImpl>());
  });
}
