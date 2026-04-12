import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/search_movie.dart';

// 🎯 Mock the MovieRepository
class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  // 📦 Setup variables
  late SearchMovies searchMovies;
  late MockMovieRepository mockMovieRepository;

  // 🏗️ Initialize dependencies before each test
  setUp(() {
    mockMovieRepository = MockMovieRepository();
    searchMovies = SearchMovies(mockMovieRepository);
  });

  // 📝 Sample test data
  final tMovieModel = MovieModel(
    id: 1,
    title: "Inception",
    overview: "A skilled thief who steals corporate secrets...",
    posterPath: "/posters/inception.jpg",
    rating: 8.8,
    releaseDate: "2010-07-16",
  );

  // ✅ TEST 1: Successfully searching for movies
  // 📌 Purpose: Verify search returns movies matching the query
  test(
    'SearchMovies should return list of movies matching query',
    () async {
      // 🔧 Arrange: Mock repository to return search results
      final tSearchResults = [tMovieModel.toEntity()];

      when(() => mockMovieRepository.searchMovies('Inception', 1))
          .thenAnswer((_) async => tSearchResults);

      // 🎬 Act: Search for movies
      final params = SearchParams(query: 'Inception', page: 1);
      final result = await searchMovies(params);

      // ✔️ Assert: Verify search results
      expect(result, tSearchResults);
      expect(result.length, 1);
      expect(result.first.title, 'Inception');

      // 🔍 Verify: Repository was called with correct parameters
      verify(() => mockMovieRepository.searchMovies('Inception', 1)).called(1);
    },
  );

  // ✅ TEST 2: Search with pagination
  // 📌 Purpose: Verify search works across multiple pages
  test(
    'SearchMovies should handle pagination correctly',
    () async {
      // 🔧 Arrange: Setup mock for page 2
      final tSearchResults = [tMovieModel.toEntity()];

      when(() => mockMovieRepository.searchMovies('Matrix', 2))
          .thenAnswer((_) async => tSearchResults);

      // 🎬 Act: Search on page 2
      final params = SearchParams(query: 'Matrix', page: 2);
      final result = await searchMovies(params);

      // ✔️ Assert: Verify correct page was used
      expect(result, tSearchResults);
      verify(() => mockMovieRepository.searchMovies('Matrix', 2)).called(1);
    },
  );

  // ✅ TEST 3: Empty search results
  // 📌 Purpose: Verify behavior when search finds no movies
  test(
    'SearchMovies should return empty list when no results found',
    () async {
      // 🔧 Arrange: Mock repository to return empty list
      when(() => mockMovieRepository.searchMovies('NonexistentMovie', 1))
          .thenAnswer((_) async => []);

      // 🎬 Act: Search for nonexistent movie
      final params = SearchParams(query: 'NonexistentMovie', page: 1);
      final result = await searchMovies(params);

      // ✔️ Assert: Verify empty list is returned
      expect(result, isEmpty);
    },
  );

  // ✅ TEST 4: Search with special characters
  // 📌 Purpose: Verify search handles special characters in query
  test(
    'SearchMovies should handle special characters in query',
    () async {
      // 🔧 Arrange: Mock repository for special character search
      final tSearchResults = [tMovieModel.toEntity()];

      when(() => mockMovieRepository.searchMovies("Harry & Potter", 1))
          .thenAnswer((_) async => tSearchResults);

      // 🎬 Act: Search with special characters
      final params = SearchParams(query: "Harry & Potter", page: 1);
      final result = await searchMovies(params);

      // ✔️ Assert: Verify special characters are handled
      expect(result, tSearchResults);
      verify(() => mockMovieRepository.searchMovies("Harry & Potter", 1))
          .called(1);
    },
  );

  // ✅ TEST 5: Multiple search results
  // 📌 Purpose: Verify search returns multiple movies correctly
  test(
    'SearchMovies should return multiple movies',
    () async {
      // 🔧 Arrange: Create two movie models
      final tMovieModel2 = MovieModel(
        id: 2,
        title: "Interstellar",
        overview: "A team of explorers travel through a wormhole...",
        posterPath: "/posters/interstellar.jpg",
        rating: 8.6,
        releaseDate: "2014-11-07",
      );

      final tSearchResults = [tMovieModel.toEntity(), tMovieModel2.toEntity()];

      when(() => mockMovieRepository.searchMovies('Space', 1))
          .thenAnswer((_) async => tSearchResults);

      // 🎬 Act: Search for space movies
      final params = SearchParams(query: 'Space', page: 1);
      final result = await searchMovies(params);

      // ✔️ Assert: Verify multiple results
      expect(result.length, 2);
      expect(result[0].title, 'Inception');
      expect(result[1].title, 'Interstellar');
    },
  );

  // ✅ TEST 6: Exception handling
  // 📌 Purpose: Verify exceptions are properly propagated
  test(
    'SearchMovies should throw exception on repository error',
    () async {
      // 🔧 Arrange: Mock repository to throw exception
      when(() => mockMovieRepository.searchMovies('Test', 1))
          .thenThrow(Exception('Network error'));

      // 🎬 Act & Assert: Verify exception is thrown
      final params = SearchParams(query: 'Test', page: 1);
      expect(
        () => searchMovies(params),
        throwsException,
      );
    },
  );
}
