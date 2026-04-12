import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_favourite.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';

// 🎯 Mock the MovieRepository
class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  // 📦 Setup variables for ToggleFavourite
  late ToggleFavourite toggleFavourite;
  late GetFavourite getFavourite;
  late MockMovieRepository mockMovieRepository;

  // 🏗️ Initialize before each test
  setUp(() {
    mockMovieRepository = MockMovieRepository();
    toggleFavourite = ToggleFavourite(mockMovieRepository);
    getFavourite = GetFavourite(mockMovieRepository);
  });

  // 📝 Sample test data
  final tMovieModel = MovieModel(
    id: 1,
    title: "The Matrix",
    overview: "A computer hacker learns about the true nature of reality...",
    posterPath: "/posters/matrix.jpg",
    rating: 8.7,
    releaseDate: "1999-03-31",
  );

  // ============================================
  // 🔥 TOGGLE FAVOURITE TESTS
  // ============================================

  // ✅ TEST 1: Successfully toggle favorite
  // 📌 Purpose: Verify usecase calls repository to toggle favorite status
  test(
    'ToggleFavourite should call repository.toggleFavorite',
    () async {
      // 🔧 Arrange: Mock repository to return success
      when(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .thenAnswer((_) async => {});

      // 🎬 Act: Toggle favorite
      await toggleFavourite(tMovieModel.toEntity());

      // ✔️ Assert: Verify repository was called
      verify(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .called(1);
    },
  );

  // ✅ TEST 2: Toggle favorite with different movie
  // 📌 Purpose: Verify correct movie is toggled
  test(
    'ToggleFavourite should toggle correct movie',
    () async {
      // 🔧 Arrange: Create different movie
      final differentMovie = MovieModel(
        id: 2,
        title: "The Dark Knight",
        overview: "When the menace known as the Joker wreaks...",
        posterPath: "/posters/darkknight.jpg",
        rating: 9.0,
        releaseDate: "2008-07-18",
      ).toEntity();

      when(() => mockMovieRepository.toggleFavorite(differentMovie))
          .thenAnswer((_) async => {});

      // 🎬 Act: Toggle different movie
      await toggleFavourite(differentMovie);

      // ✔️ Assert: Verify correct movie was toggled
      verify(() => mockMovieRepository.toggleFavorite(differentMovie))
          .called(1);
      verifyNever(
          () => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()));
    },
  );

  // ✅ TEST 3: Multiple toggle operations
  // 📌 Purpose: Verify consecutive toggle operations work correctly
  test(
    'ToggleFavourite should handle multiple toggles',
    () async {
      // 🔧 Arrange: Setup mock for multiple calls
      when(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .thenAnswer((_) async => {});

      // 🎬 Act: Toggle same movie multiple times (add, remove, add)
      await toggleFavourite(tMovieModel.toEntity());
      await toggleFavourite(tMovieModel.toEntity());
      await toggleFavourite(tMovieModel.toEntity());

      // ✔️ Assert: Verify all three calls were made
      verify(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .called(3);
    },
  );

  // ✅ TEST 4: Exception handling in toggle
  // 📌 Purpose: Verify exceptions are properly propagated
  test(
    'ToggleFavourite should throw exception on repository error',
    () async {
      // 🔧 Arrange: Mock repository to throw exception
      when(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .thenThrow(Exception('Database error'));

      // 🎬 Act & Assert: Verify exception is thrown
      expect(
        () => toggleFavourite(tMovieModel.toEntity()),
        throwsException,
      );
    },
  );

  // ============================================
  // 🔥 GET FAVOURITE TESTS
  // ============================================

  // ✅ TEST 5: Successfully get favorite movies
  // 📌 Purpose: Verify usecase returns list of favorite movies
  test(
    'GetFavourite should return list of favorite movies',
    () async {
      // 🔧 Arrange: Create favorite movies list
      final tFavoriteMovies = [tMovieModel.toEntity()];

      when(() => mockMovieRepository.getFavoriteMovies())
          .thenAnswer((_) async => tFavoriteMovies);

      // 🎬 Act: Get favorites (using NoParams)
      final result = await getFavourite(NoParams());

      // ✔️ Assert: Verify favorites list is returned
      expect(result, tFavoriteMovies);
      expect(result.length, 1);
      expect(result.first.title, "The Matrix");

      // 🔍 Verify: Repository was called
      verify(() => mockMovieRepository.getFavoriteMovies()).called(1);
    },
  );

  // ✅ TEST 6: Get multiple favorite movies
  // 📌 Purpose: Verify multiple favorites are returned
  test(
    'GetFavourite should return multiple favorite movies',
    () async {
      // 🔧 Arrange: Create multiple movies
      final movie2 = MovieModel(
        id: 2,
        title: "Inception",
        overview: "A skilled thief who steals corporate secrets...",
        posterPath: "/posters/inception.jpg",
        rating: 8.8,
        releaseDate: "2010-07-16",
      ).toEntity();

      final tFavoriteMovies = [tMovieModel.toEntity(), movie2];

      when(() => mockMovieRepository.getFavoriteMovies())
          .thenAnswer((_) async => tFavoriteMovies);

      // 🎬 Act: Get favorites
      final result = await getFavourite(NoParams());

      // ✔️ Assert: Verify multiple movies are returned
      expect(result.length, 2);
      expect(result[0].title, "The Matrix");
      expect(result[1].title, "Inception");
    },
  );

  // ✅ TEST 7: Get empty favorites (no saved favorites)
  // 📌 Purpose: Verify empty list handling
  test(
    'GetFavourite should return empty list when no favorites',
    () async {
      // 🔧 Arrange: Mock repository to return empty list
      when(() => mockMovieRepository.getFavoriteMovies())
          .thenAnswer((_) async => []);

      // 🎬 Act: Get favorites
      final result = await getFavourite(NoParams());

      // ✔️ Assert: Verify empty list
      expect(result, isEmpty);
    },
  );

  // ✅ TEST 8: Exception handling in get favorites
  // 📌 Purpose: Verify error handling when fetching fails
  test(
    'GetFavourite should throw exception on repository error',
    () async {
      // 🔧 Arrange: Mock repository to throw exception
      when(() => mockMovieRepository.getFavoriteMovies())
          .thenThrow(Exception('Database error'));

      // 🎬 Act & Assert: Verify exception is thrown
      expect(
        () => getFavourite(NoParams()),
        throwsException,
      );
    },
  );

  // ✅ TEST 9: Integration test - Toggle and Get Favorites
  // 📌 Purpose: Verify workflow of adding favorite and retrieving it
  test(
    'Should toggle favorite and retrieve in favorites list',
    () async {
      // 🔧 Arrange: Setup mocks
      when(() => mockMovieRepository.toggleFavorite(tMovieModel.toEntity()))
          .thenAnswer((_) async => {});

      when(() => mockMovieRepository.getFavoriteMovies())
          .thenAnswer((_) async => [tMovieModel.toEntity()]);

      // 🎬 Act: Toggle favorite, then get favorites
      await toggleFavourite(tMovieModel.toEntity());
      final favorites = await getFavourite(NoParams());

      // ✔️ Assert: Verify movie appears in favorites
      expect(favorites.length, 1);
      expect(favorites.first.id, tMovieModel.id);
    },
  );

  // ✅ TEST 10: Get favorite movies multiple times
  // 📌 Purpose: Verify consistent results on multiple calls
  test(
    'GetFavourite should return consistent results',
    () async {
      // 🔧 Arrange: Setup mock
      final tFavoriteMovies = [tMovieModel.toEntity()];

      when(() => mockMovieRepository.getFavoriteMovies())
          .thenAnswer((_) async => tFavoriteMovies);

      // 🎬 Act: Call multiple times
      final result1 = await getFavourite(NoParams());
      final result2 = await getFavourite(NoParams());

      // ✔️ Assert: Verify same results both times
      expect(result1, result2);
      expect(result1.first.id, result2.first.id);
    },
  );
}
