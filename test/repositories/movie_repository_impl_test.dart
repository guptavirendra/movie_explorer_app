import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/core/network/network_info.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_local_datasource.dart';
import 'package:movie_explorer_app/features/movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/data/repositories/movie_repositories_impl.dart';

// 🎯 Mock classes for dependencies
class MockRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockLocalDataSource extends Mock implements MovieLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// 🔧 Fallback values for mocktail
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  // 📦 Setup variables
  late MovieRepositoriesImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  // 🏗️ Initialize before each test
  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = MovieRepositoriesImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
    );
  });

  // 📝 Sample test data
  final tMovieModel = MovieModel(
    id: 1,
    title: "Test Movie",
    overview: "Overview",
    posterPath: "/test.jpg",
    rating: 8.5,
    releaseDate: "2024-01-01",
  );

  // ============================================
  // 🔥 GET POPULAR MOVIES TESTS
  // ============================================

  // ✅ TEST 1: Successfully get popular movies when connected to internet
  // 📌 Purpose: Verify repository fetches and converts popular movies correctly
  test(
    'getPopularMovies should return MovieResponse when network is connected',
    () async {
      // 🔧 Arrange: Setup conditions for successful fetch
      // - Network is connected
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // - Remote datasource returns mock data
      when(() => mockRemoteDataSource.getPopularMovies(1)).thenAnswer(
        (_) async => {
          "results": [tMovieModel],
          "totalPages": 10,
        },
      );

      // 🎬 Act: Call getPopularMovies
      final result = await repository.getPopularMovies(1);

      // ✔️ Assert: Verify result structure and data
      expect(result, isNotNull);
      expect(result.movies, isNotEmpty);
      expect(result.movies.first.id, 1);
      expect(result.totalPages, 10);

      // 🔍 Verify: Correct methods were called
      verify(() => mockNetworkInfo.isConnected).called(1);
      verify(() => mockRemoteDataSource.getPopularMovies(1)).called(1);
    },
  );

  // ✅ TEST 2: Throw NetworkFailure when no internet connection
  // 📌 Purpose: Verify proper error handling for offline scenarios
  test(
    'getPopularMovies should throw NetworkFailure when offline',
    () async {
      // 🔧 Arrange: Simulate offline scenario
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // 🎬 Act & Assert: Verify NetworkFailure is thrown
      expect(
        () => repository.getPopularMovies(1),
        throwsA(isA<NetworkFailure>()),
      );

      // 🔍 Verify: Remote datasource was never called
      verifyNever(() => mockRemoteDataSource.getPopularMovies(any()));
    },
  );

  // ✅ TEST 3: Handle server errors gracefully
  // 📌 Purpose: Verify ServerFailure is thrown on server errors
  test(
    'getPopularMovies should throw ServerFailure on server error',
    () async {
      // 🔧 Arrange: Setup network connected but server error
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPopularMovies(1))
          .thenThrow(ServerException(message: 'Server error', statusCode: 500));

      // 🎬 Act & Assert: Verify ServerFailure is thrown
      expect(
        () => repository.getPopularMovies(1),
        throwsA(isA<ServerFailure>()),
      );
    },
  );

  // ✅ TEST 4: Pagination support for popular movies
  // 📌 Purpose: Verify repository correctly handles different page numbers
  test(
    'getPopularMovies should handle different page numbers',
    () async {
      // 🔧 Arrange: Setup for page 2
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPopularMovies(2)).thenAnswer(
        (_) async => {
          "results": [tMovieModel],
          "totalPages": 10,
        },
      );

      // 🎬 Act: Request page 2
      final result = await repository.getPopularMovies(2);

      // ✔️ Assert: Verify correct page was fetched
      expect(result, isNotNull);
      verify(() => mockRemoteDataSource.getPopularMovies(2)).called(1);
    },
  );

  // ============================================
  // 🔥 GET MOVIE DETAILS TESTS
  // ============================================

  // ✅ TEST 5: Successfully get movie details
  // 📌 Purpose: Verify detailed movie information retrieval
  test(
    'getMovieDetails should return Movie when successful',
    () async {
      // 🔧 Arrange: Mock dataset returns valid movie
      when(() => mockRemoteDataSource.getMovieDetails(1))
          .thenAnswer((_) async => tMovieModel);

      // 🎬 Act: Get movie details
      final result = await repository.getMovieDetails(1);

      // ✔️ Assert: Verify movie data is returned
      expect(result, isNotNull);
      expect(result.id, 1);
      expect(result.title, "Test Movie");

      // 🔍 Verify: Remote datasource was called
      verify(() => mockRemoteDataSource.getMovieDetails(1)).called(1);
    },
  );

  // ✅ TEST 6: Handle network error in getMovieDetails
  // 📌 Purpose: Verify network errors are converted to NetworkFailure
  test(
    'getMovieDetails should throw NetworkFailure on connection error',
    () async {
      // 🔧 Arrange: Simulate connection error
      when(() => mockRemoteDataSource.getMovieDetails(1))
          .thenThrow(DioException(requestOptions: FakeRequestOptions()));

      // 🎬 Act & Assert: Verify NetworkFailure is thrown
      expect(
        () => repository.getMovieDetails(1),
        throwsA(isA<NetworkFailure>()),
      );
    },
  );

  // ============================================
  // 🔥 SEARCH MOVIES TESTS
  // ============================================

  // ✅ TEST 7: Successfully search movies
  // 📌 Purpose: Verify search returns correct movie list
  test(
    'searchMovies should return list of movies',
    () async {
      // 🔧 Arrange: Setup search results
      when(() => mockRemoteDataSource.searchMovies('Inception', 1))
          .thenAnswer((_) async => [tMovieModel]);

      // 🎬 Act: Search for movies
      final result = await repository.searchMovies('Inception', 1);

      // ✔️ Assert: Verify search results
      expect(result, isNotEmpty);
      expect(result.first.title, "Test Movie");

      // 🔍 Verify: Search method was called
      verify(() => mockRemoteDataSource.searchMovies('Inception', 1)).called(1);
    },
  );

  // ✅ TEST 8: Handle search with no results
  // 📌 Purpose: Verify empty list handling in search
  test(
    'searchMovies should return empty list when no results',
    () async {
      // 🔧 Arrange: Setup empty search results
      when(() => mockRemoteDataSource.searchMovies('Nonexistent', 1))
          .thenAnswer((_) async => []);

      // 🎬 Act: Search for nonexistent movie
      final result = await repository.searchMovies('Nonexistent', 1);

      // ✔️ Assert: Verify empty list
      expect(result, isEmpty);
    },
  );

  // ============================================
  // 🔥 TOGGLE FAVORITE TESTS
  // ============================================

  // ✅ TEST 9: Successfully toggle favorite
  // 📌 Purpose: Verify favorite toggle saves to local storage
  test(
    'toggleFavorite should save movie to local storage',
    () async {
      // 🔧 Arrange: Mock local storage
      when(() => mockLocalDataSource.toggleFavorite(tMovieModel))
          .thenAnswer((_) async => {});

      // 🎬 Act: Toggle favorite
      await repository.toggleFavorite(tMovieModel.toEntity());

      // 🔍 Verify: Local datasource was called
      verify(() => mockLocalDataSource.toggleFavorite(any())).called(1);
    },
  );

  // ============================================
  // 🔥 GET FAVORITE MOVIES TESTS
  // ============================================

  // ✅ TEST 10: Successfully get favorite movies
  // 📌 Purpose: Verify favorite movies are retrieved from local storage
  test(
    'getFavoriteMovies should return list of favorite movies',
    () async {
      // 🔧 Arrange: Mock local storage returns favorites
      when(() => mockLocalDataSource.getFavorites())
          .thenAnswer((_) async => [tMovieModel]);

      // 🎬 Act: Get favorites
      final result = await repository.getFavoriteMovies();

      // ✔️ Assert: Verify favorites list
      expect(result, isNotEmpty);
      expect(result.first.id, 1);

      // 🔍 Verify: Local datasource was called
      verify(() => mockLocalDataSource.getFavorites()).called(1);
    },
  );

  // ✅ TEST 11: Get empty favorites
  // 📌 Purpose: Verify empty list handling in favorites
  test(
    'getFavoriteMovies should return empty list when no favorites',
    () async {
      // 🔧 Arrange: Mock empty favorites
      when(() => mockLocalDataSource.getFavorites())
          .thenAnswer((_) async => []);

      // 🎬 Act: Get favorites
      final result = await repository.getFavoriteMovies();

      // ✔️ Assert: Verify empty list
      expect(result, isEmpty);
    },
  );

  // ============================================
  // 🔥 DATA LAYER INTEGRATION TESTS
  // ============================================

  // ✅ TEST 12: Multiple operations in sequence
  // 📌 Purpose: Verify repository handles sequential operations correctly
  test(
    'repository should handle sequential operations',
    () async {
      // 🔧 Arrange: Setup all mocks
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPopularMovies(1)).thenAnswer(
        (_) async => {
          "results": [tMovieModel],
          "totalPages": 1,
        },
      );
      when(() => mockRemoteDataSource.getMovieDetails(1))
          .thenAnswer((_) async => tMovieModel);
      when(() => mockLocalDataSource.toggleFavorite(tMovieModel))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.getFavorites())
          .thenAnswer((_) async => [tMovieModel]);

      // 🎬 Act: Execute sequence of operations
      final popularMovies = await repository.getPopularMovies(1);
      final details = await repository.getMovieDetails(1);
      await repository.toggleFavorite(details);
      final favorites = await repository.getFavoriteMovies();

      // ✔️ Assert: All operations completed successfully
      expect(popularMovies.movies, isNotEmpty);
      expect(details, isNotNull);
      expect(favorites, isNotEmpty);
    },
  );
}

// 🔥 Extension for DioException
extension on DioException {}
