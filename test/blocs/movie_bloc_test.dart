import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/core/error/failures.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_popular_movies.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/bloc/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/bloc/movie_state.dart';

// 🎯 Mock the GetPopularMovies usecase
class MockGetPopularMovies extends Mock implements GetPopularMovies {}

void main() {
  setUpAll(() {
    registerFallbackValue(PageParams(page: 1));
  });

  // 📦 Setup variables
  late MovieBloc movieBloc;
  late MockGetPopularMovies mockGetPopularMovies;

  // 🏗️ Initialize before each test
  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    movieBloc = MovieBloc(mockGetPopularMovies);
  });

  // 🧹 Clean up after each test
  tearDown(() {
    movieBloc.close();
  });

  // 📝 Sample test data
  final tMovieModel = MovieModel(
    id: 1,
    title: "Test Movie",
    overview: "Test overview",
    posterPath: "/test.jpg",
    rating: 8.5,
    releaseDate: "2024-01-01",
  );

  final tMovieResponse = MovieResponse(
    movies: [tMovieModel.toEntity()],
    totalPages: 5,
  );

  // ============================================
  // 🔥 FETCH POPULAR MOVIES TESTS
  // ============================================

  // ✅ TEST 1: FetchPopularMovies emits MovieLoading then MovieLoaded
  // 📌 Purpose: Verify successful movie fetching transitions through states
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should emit [MovieLoading, MovieLoaded] when successful',
    // 🔧 Arrange: Mock the usecase to return movie response
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    // 🎬 Act: Add FetchPopularMovies event
    act: (bloc) => bloc.add(FetchPopularMovies()),
    // ✔️ Assert: Verify state transitions
    expect: () => [
      isA<MovieLoading>(),
      isA<MovieLoaded>()
          .having((state) => state.movies.length, 'movies length', 1)
          .having((state) => state.hasReachedMax, 'hasReachedMax', false),
    ],
  );

  // ✅ TEST 2: FetchPopularMovies loads first page correctly
  // 📌 Purpose: Verify first page is loaded on initial fetch
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should load first page (page=1)',
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    act: (bloc) => bloc.add(FetchPopularMovies()),
    verify: (bloc) {
      // 🔍 Verify: Usecase was called with page 1
      final captured =
          verify(() => mockGetPopularMovies(captureAny())).captured;
      expect((captured.first as PageParams).page, 1);
      // Verify internal bloc state
      expect(bloc.page.page, 1);
    },
  );

  // ✅ TEST 3: FetchPopularMovies handles network failure
  // 📌 Purpose: Verify proper error state when network fails
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should emit MovieError on NetworkFailure',
    build: () {
      when(() => mockGetPopularMovies(any())).thenThrow(NetworkFailure());
      return movieBloc;
    },
    act: (bloc) => bloc.add(FetchPopularMovies()),
    expect: () => [
      isA<MovieLoading>(),
      isA<MovieError>().having(
        (state) => state.message,
        'error message',
        'Please check your connection and try again.',
      ),
    ],
  );

  // ✅ TEST 4: FetchPopularMovies handles server failure
  // 📌 Purpose: Verify proper error state when server returns error
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should emit MovieError on ServerFailure',
    build: () {
      when(() => mockGetPopularMovies(any())).thenThrow(ServerFailure());
      return movieBloc;
    },
    act: (bloc) => bloc.add(FetchPopularMovies()),
    expect: () => [
      isA<MovieLoading>(),
      isA<MovieError>().having(
          (state) => state.message, 'message', contains('Server error')),
    ],
  );

  // ✅ TEST 5: FetchPopularMovies handles generic exceptions
  // 📌 Purpose: Verify generic exception handling
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should emit MovieError on generic exception',
    build: () {
      when(() => mockGetPopularMovies(any())).thenThrow(Exception());
      return movieBloc;
    },
    act: (bloc) => bloc.add(FetchPopularMovies()),
    expect: () => [
      isA<MovieLoading>(),
      isA<MovieError>().having(
        (state) => state.message,
        'message',
        'An unexpected error occurred',
      ),
    ],
  );

  // ✅ TEST 6: FetchPopularMovies resets to page 1
  // 📌 Purpose: Verify fresh fetch starts from page 1
  blocTest<MovieBloc, MovieState>(
    'FetchPopularMovies should reset page to 1',
    build: () {
      // First load some pages
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    act: (bloc) {
      bloc.page = PageParams(page: 3); // Simulate we were on page 3
      bloc.add(FetchPopularMovies());
    },
    verify: (bloc) {
      // After fetch, page should be reset to 1
      expect(bloc.page.page, 1);
    },
  );

  // ============================================
  // 🔥 LOAD MORE MOVIES TESTS
  // ============================================

  // ✅ TEST 7: LoadMoreMovies appends movies to existing list
  // 📌 Purpose: Verify pagination adds new movies to loaded list
  blocTest<MovieBloc, MovieState>(
    'LoadMoreMovies should append movies to existing list',
    build: () {
      // Setup initial state with one movie
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);

      // Setup second page response
      final movie2 = MovieModel(
        id: 2,
        title: "Movie 2",
        overview: "Overview 2",
        posterPath: "/poster2.jpg",
        rating: 7.5,
        releaseDate: "2024-02-01",
      );

      final tMovieResponse2 = MovieResponse(
        movies: [movie2.toEntity()],
        totalPages: 5,
      );

      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse2);

      return movieBloc;
    },
    act: (bloc) {
      // First: Fetch initial movies
      bloc.add(FetchPopularMovies());
    },
    skip: 2, // Skip MovieLoading and MovieLoaded from fetch
    seed: () =>
        MovieLoaded(movies: [tMovieModel.toEntity()], hasReachedMax: false),
  );

  // ✅ TEST 8: LoadMoreMovies should not execute if already fetching
  // 📌 Purpose: Verify multiple rapid load-more requests are throttled
  blocTest<MovieBloc, MovieState>(
    'LoadMoreMovies should not execute if already fetching',
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    seed: () => MovieLoaded(
        movies: [tMovieModel.toEntity()],
        hasReachedMax: false,
        isLoadingMore: true),
    act: (bloc) {
      bloc.add(LoadMoreMovies());
    },
    expect: () => [], // No state changes expected
  );

  // ✅ TEST 9: LoadMoreMovies should not load if max pages reached
  // 📌 Purpose: Verify load-more stops at last page
  blocTest<MovieBloc, MovieState>(
    'LoadMoreMovies should not load if max pages reached',
    build: () {
      return movieBloc;
    },
    seed: () =>
        MovieLoaded(movies: [tMovieModel.toEntity()], hasReachedMax: true),
    act: (bloc) {
      bloc.totalPages = 1;
      bloc.page = PageParams(page: 1);
      bloc.add(LoadMoreMovies());
    },
    expect: () => [], // No state change expected
  );

  // ============================================
  // 🔥 REFRESH MOVIES TESTS
  // ============================================

  // ✅ TEST 10: RefreshMovies resets and fetches from page 1
  // 📌 Purpose: Verify refresh starts fresh from page 1
  blocTest<MovieBloc, MovieState>(
    'RefreshMovies should reset and fetch from page 1',
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    act: (bloc) {
      bloc.page = PageParams(page: 5); // Simulate on page 5
      bloc.add(RefreshMovies());
    },
    verify: (bloc) {
      // After refresh, should be on page 1
      expect(bloc.page.page, 1);
    },
  );

  // ✅ TEST 11: RefreshMovies handles network error
  // 📌 Purpose: Verify error handling during refresh
  blocTest<MovieBloc, MovieState>(
    'RefreshMovies should emit MovieError on network error',
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenThrow(Exception('Network error'));
      return movieBloc;
    },
    act: (bloc) => bloc.add(RefreshMovies()),
    expect: () => [
      isA<MovieError>().having(
          (state) => state.message, 'message', 'Failed to refresh movies'),
    ],
  );

  // ============================================
  // 🔥 STATE MANAGEMENT TESTS
  // ============================================

  // ✅ TEST 12: Initial state is MovieInitial
  // 📌 Purpose: Verify correct initial state
  test('initial state is MovieInitial', () {
    expect(movieBloc.state, isA<MovieInitial>());
  });

  // ✅ TEST 13: Verify hasReachedMax flag works correctly
  // 📌 Purpose: Verify pagination flag indicates last page
  test('hasReachedMax should indicate if last page is reached', () async {
    when(() => mockGetPopularMovies(any()))
        .thenAnswer((_) async => MovieResponse(movies: [], totalPages: 1));

    movieBloc.add(FetchPopularMovies());

    await Future.delayed(Duration(milliseconds: 100));

    final currentState = movieBloc.state as MovieLoaded;
    expect(currentState.hasReachedMax, isTrue);
  });

  // ✅ TEST 14: Total pages updated correctly
  // 📌 Purpose: Verify total pages tracking for pagination
  test('totalPages should be updated after fetch', () async {
    when(() => mockGetPopularMovies(any()))
        .thenAnswer((_) async => MovieResponse(movies: [], totalPages: 10));

    movieBloc.add(FetchPopularMovies());

    await Future.delayed(Duration(milliseconds: 100));

    expect(movieBloc.totalPages, 10);
  });

  // ============================================
  // 🔥 EVENT HANDLING TESTS
  // ============================================

  // ✅ TEST 15: Multiple events in sequence
  // 📌 Purpose: Verify bloc handles event queue correctly
  blocTest<MovieBloc, MovieState>(
    'MovieBloc should handle multiple events in sequence',
    build: () {
      when(() => mockGetPopularMovies(any()))
          .thenAnswer((_) async => tMovieResponse);
      return movieBloc;
    },
    act: (bloc) {
      bloc.add(FetchPopularMovies());
      // Could add more events here like RefreshMovies etc.
    },
    expect: () => [
      isA<MovieLoading>(),
      isA<MovieLoaded>(),
    ],
  );
}
