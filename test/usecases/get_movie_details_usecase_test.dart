import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_movie_details.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

// 🎯 Mock the MovieRepository
class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  // 📦 Setup variables
  late GetMovieDetails getMovieDetails;
  late MockMovieRepository mockMovieRepository;

  // 🏗️ Initialize before each test
  setUp(() {
    mockMovieRepository = MockMovieRepository();
    getMovieDetails = GetMovieDetails(mockMovieRepository);
  });

  // 📝 Sample test data
  final tMovieModel = MovieModel(
    id: 550,
    title: "Fight Club",
    overview: "An insomniac office worker and a devil-may-care soap maker...",
    posterPath: "/posters/fightclub.jpg",
    rating: 8.8,
    releaseDate: "1999-10-15",
  );

  // ✅ TEST 1: Successfully fetch movie details
  // 📌 Purpose: Verify usecase returns correct movie details for a given ID
  test(
    'GetMovieDetails should return movie when repository succeeds',
    () async {
      // 🔧 Arrange: Mock repository to return movie details
      when(() => mockMovieRepository.getMovieDetails(550))
          .thenAnswer((_) async => tMovieModel.toEntity());

      // 🎬 Act: Get details for movie ID 550
      final params = MovieDetailsParams(550);
      final result = await getMovieDetails(params);

      // ✔️ Assert: Verify movie details are correct
      expect(result, tMovieModel.toEntity());
      expect(result.id, 550);
      expect(result.title, 'Fight Club');
      expect(result.rating, 8.8);

      // 🔍 Verify: Repository was called exactly once with correct ID
      verify(() => mockMovieRepository.getMovieDetails(550)).called(1);
    },
  );

  // ✅ TEST 2: Different movie IDs
  // 📌 Purpose: Verify usecase correctly passes different movie IDs
  test(
    'GetMovieDetails should call repository with correct movie ID',
    () async {
      // 🔧 Arrange: Setup mock for different movie ID
      when(() => mockMovieRepository.getMovieDetails(100))
          .thenAnswer((_) async => tMovieModel.toEntity());

      // 🎬 Act: Request movie with ID 100
      final params = MovieDetailsParams(100);
      await getMovieDetails(params);

      // ✔️ Assert: Verify correct movie ID was passed
      verify(() => mockMovieRepository.getMovieDetails(100)).called(1);
    },
  );

  // ✅ TEST 3: Movie with complete details
  // 📌 Purpose: Verify all movie fields are properly returned
  test(
    'GetMovieDetails should return movie with all details',
    () async {
      // 🔧 Arrange: Create detailed movie model
      final detailedMovie = MovieModel(
        id: 550,
        title: "Fight Club",
        overview:
            "An insomniac office worker and a devil-may-care soap maker...",
        posterPath: "/posters/fightclub.jpg",
        rating: 8.8,
        releaseDate: "1999-10-15",
      );

      when(() => mockMovieRepository.getMovieDetails(550))
          .thenAnswer((_) async => detailedMovie.toEntity());

      // 🎬 Act: Get movie details
      final params = MovieDetailsParams(550);
      final result = await getMovieDetails(params);

      // ✔️ Assert: Verify all fields are present
      expect(result.id, 550);
      expect(result.title, isNotEmpty);
      expect(result.overview, isNotEmpty);
      expect(result.posterPath, isNotEmpty);
      expect(result.rating, isPositive);
      expect(result.releaseDate, isNotEmpty);
    },
  );

  // ✅ TEST 4: Invalid movie ID
  // 📌 Purpose: Verify behavior when movie ID doesn't exist
  test(
    'GetMovieDetails should throw exception for invalid movie ID',
    () async {
      // 🔧 Arrange: Mock repository to throw exception for invalid ID
      when(() => mockMovieRepository.getMovieDetails(99999))
          .thenThrow(Exception('Movie not found'));

      // 🎬 Act & Assert: Verify exception is thrown
      final params = MovieDetailsParams(99999);
      expect(
        () => getMovieDetails(params),
        throwsException,
      );
    },
  );

  // ✅ TEST 5: Multiple sequential requests
  // 📌 Purpose: Verify usecase can handle multiple requests
  test(
    'GetMovieDetails should handle multiple sequential requests',
    () async {
      // 🔧 Arrange: Setup mocks for multiple IDs
      final movie1 = MovieModel(
              id: 1,
              title: "Movie 1",
              overview: "Overview 1",
              posterPath: "/1.jpg",
              rating: 8.0,
              releaseDate: "2020-01-01")
          .toEntity();
      final movie2 = MovieModel(
              id: 2,
              title: "Movie 2",
              overview: "Overview 2",
              posterPath: "/2.jpg",
              rating: 7.5,
              releaseDate: "2020-02-01")
          .toEntity();

      when(() => mockMovieRepository.getMovieDetails(1))
          .thenAnswer((_) async => movie1);
      when(() => mockMovieRepository.getMovieDetails(2))
          .thenAnswer((_) async => movie2);

      // 🎬 Act: Make two requests
      final result1 = await getMovieDetails(MovieDetailsParams(1));
      final result2 = await getMovieDetails(MovieDetailsParams(2));

      // ✔️ Assert: Verify both requests returned correct data
      expect(result1.id, 1);
      expect(result2.id, 2);
      verify(() => mockMovieRepository.getMovieDetails(1)).called(1);
      verify(() => mockMovieRepository.getMovieDetails(2)).called(1);
    },
  );

  // ✅ TEST 6: Network error handling
  // 📌 Purpose: Verify exception propagation on network errors
  test(
    'GetMovieDetails should propagate network errors',
    () async {
      // 🔧 Arrange: Mock network error
      when(() => mockMovieRepository.getMovieDetails(550))
          .thenThrow(Exception('Network timeout'));

      // 🎬 Act & Assert: Verify error is propagated
      final params = MovieDetailsParams(550);
      expect(
        () => getMovieDetails(params),
        throwsException,
      );
    },
  );
}
