import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_popular_movies.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

// 🎯 Mock the MovieRepository since we're testing the usecase, not the repository
class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  // 📦 Setup: Declare variables for late initialization
  late GetPopularMovies getPopularMovies;
  late MockMovieRepository mockMovieRepository;

  // 🏗️ setUp runs before each test to initialize the test dependencies
  setUp(() {
    mockMovieRepository = MockMovieRepository();
    getPopularMovies = GetPopularMovies(mockMovieRepository);
  });

  // 📝 Sample test data: Create a dummy movie model for testing
  final tMovieModel = MovieModel(
    id: 1,
    title: "The Shawshank Redemption",
    overview: "Two imprisoned men bond over a number of years...",
    posterPath: "/posters/shawshank.jpg",
    rating: 9.3,
    releaseDate: "1994-10-14",
  );

  // ✅ TEST 1: Successfully fetching popular movies
  // 📌 Purpose: Verify the usecase returns MovieResponse when repository succeeds
  test(
    'GetPopularMovies should return MovieResponse when repository call succeeds',
    () async {
      // 🔧 Arrange: Mock the repository to return a valid MovieResponse
      final tMovieResponse = MovieResponse(
        movies: [tMovieModel.toEntity()],
        totalPages: 10,
      );

      when(() => mockMovieRepository.getPopularMovies(1))
          .thenAnswer((_) async => tMovieResponse);

      // 🎬 Act: Call the usecase with page 1
      final params = PageParams(page: 1);
      final result = await getPopularMovies(params);

      // ✔️ Assert: Verify the result is correct
      expect(result, tMovieResponse);
      expect(result.movies.length, 1);
      expect(result.movies.first.title, "The Shawshank Redemption");
      expect(result.totalPages, 10);

      // 🔍 Verify: Ensure the repository was called exactly once with page 1
      verify(() => mockMovieRepository.getPopularMovies(1)).called(1);
    },
  );

  // ✅ TEST 2: Handling pagination (different pages)
  // 📌 Purpose: Verify the usecase correctly passes different page numbers
  test(
    'GetPopularMovies should call repository with correct page parameter',
    () async {
      // 🔧 Arrange: Setup mock for page 2
      final tMovieResponse =
          MovieResponse(movies: [tMovieModel.toEntity()], totalPages: 10);
      when(() => mockMovieRepository.getPopularMovies(2))
          .thenAnswer((_) async => tMovieResponse);

      // 🎬 Act: Request page 2
      final params = PageParams(page: 2);
      await getPopularMovies(params);

      // ✔️ Assert: Verify repository was called with page 2
      verify(() => mockMovieRepository.getPopularMovies(2)).called(1);
    },
  );

  // ✅ TEST 3: Handling empty results
  // 📌 Purpose: Verify usecase works correctly when no movies are returned
  test(
    'GetPopularMovies should handle empty movie list',
    () async {
      // 🔧 Arrange: Mock repository to return empty response
      final emptyResponse = MovieResponse(movies: [], totalPages: 0);
      when(() => mockMovieRepository.getPopularMovies(1))
          .thenAnswer((_) async => emptyResponse);

      // 🎬 Act: Call usecase
      final params = PageParams(page: 1);
      final result = await getPopularMovies(params);

      // ✔️ Assert: Verify empty list handling
      expect(result.movies, isEmpty);
      expect(result.totalPages, 0);
    },
  );

  // ✅ TEST 4: Exception handling
  // 📌 Purpose: Verify usecase properly propagates errors from repository
  test(
    'GetPopularMovies should throw exception when repository fails',
    () async {
      // 🔧 Arrange: Mock repository to throw exception
      when(() => mockMovieRepository.getPopularMovies(1))
          .thenThrow(Exception('Network error'));

      // 🎬 Act & Assert: Verify exception is thrown
      final params = PageParams(page: 1);
      expect(
        () => getPopularMovies(params),
        throwsException,
      );
    },
  );

  // ✅ TEST 5: Multiple movies in response
  // 📌 Purpose: Verify usecase handles multiple movies correctly
  test(
    'GetPopularMovies should return multiple movies',
    () async {
      // 🔧 Arrange: Create multiple movie models
      final tMovieModel2 = MovieModel(
        id: 2,
        title: "The Godfather",
        overview: "The aging patriarch of an organized crime dynasty...",
        posterPath: "/posters/godfather.jpg",
        rating: 9.2,
        releaseDate: "1972-03-24",
      );

      final tMultipleResponse = MovieResponse(
        movies: [tMovieModel.toEntity(), tMovieModel2.toEntity()],
        totalPages: 5,
      );

      when(() => mockMovieRepository.getPopularMovies(1))
          .thenAnswer((_) async => tMultipleResponse);

      // 🎬 Act: Call usecase
      final params = PageParams(page: 1);
      final result = await getPopularMovies(params);

      // ✔️ Assert: Verify multiple movies are returned
      expect(result.movies.length, 2);
      expect(result.movies[0].title, "The Shawshank Redemption");
      expect(result.movies[1].title, "The Godfather");
    },
  );
}
