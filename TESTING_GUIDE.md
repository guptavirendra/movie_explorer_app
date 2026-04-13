# 🎯 Complete Unit Testing Guide for Movie Explorer App

## 📋 Overview

This guide explains all unit tests for **Usecases**, **Repositories**, and **Blocs** in the Movie Explorer application using **Clean Architecture** principles.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)              │
│  - Bloc/Cubit (State Management)         │
│  - UI Widgets                            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     DOMAIN LAYER (Business Logic)        │
│  - Entities (Pure Dart)                  │
│  - Repositories (Interfaces)             │
│  - Usecases                              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     DATA LAYER (Data Sources)            │
│  - Models (mappers from APIs)            │
│  - Repository Implementations            │
│  - Remote & Local Datasources            │
└─────────────────────────────────────────┘
```

---

## 🧪 USECASE TESTS

### 1️⃣ **GetPopularMovies Usecase** (`get_popular_movies_usecase_test.dart`)

**Purpose**: Test fetching popular movies from the repository

#### Test Cases:

| # | Test Name | Description |
|---|-----------|-------------|
| 1 | Should return MovieResponse on success | ✅ Verifies successful movie fetching |
| 2 | Should pass correct page parameter | ✅ Tests pagination support |
| 3 | Should handle empty results | ✅ Tests edge case of no movies |
| 4 | Should throw exception on error | ✅ Tests error propagation |
| 5 | Should return multiple movies | ✅ Tests handling multiple results |

**Example Code Explanation**:
```dart
// 🔧 Arrange: Setup mock to return response
when(() => mockMovieRepository.getPopularMovies(1))
    .thenAnswer((_) async => tMovieResponse);

// 🎬 Act: Call the usecase
final result = await getPopularMovies(PageParams(page: 1));

// ✔️ Assert: Verify result
expect(result.movies.length, 1);
expect(result.totalPages, 10);

// 🔍 Verify: Check repository was called
verify(() => mockMovieRepository.getPopularMovies(1)).called(1);
```

**Key Concepts**:
- **Arrange-Act-Assert (AAA)**: Standard test pattern
- **Mocking**: Isolates usecase from repository dependency
- **When/Then**: Sets up mock behavior using mocktail

---

### 2️⃣ **SearchMovies Usecase** (`search_movie_usecase_test.dart`)

**Purpose**: Test movie search functionality

#### Test Cases:

| # | Test | Purpose |
|---|------|---------|
| 1 | Return search results | ✅ Verify search works |
| 2 | Handle pagination | ✅ Test different pages |
| 3 | Return empty list | ✅ No results scenario |
| 4 | Handle special chars | ✅ Query with symbols |
| 5 | Multiple results | ✅ Test multiple movies |
| 6 | Exception handling | ✅ Error propagation |

**Example - Search with pagination**:
```dart
// Testing page 2 search results
final params = SearchParams(query: 'Matrix', page: 2);
final result = await searchMovies(params);

// Verify page 2 was queried
verify(() => mockMovieRepository.searchMovies('Matrix', 2)).called(1);
```

---

### 3️⃣ **GetMovieDetails Usecase** (`get_movie_details_usecase_test.dart`)

**Purpose**: Test fetching individual movie details

#### Key Tests:
- ✅ Return movie details successfully
- ✅ Pass correct movie ID
- ✅ Handle invalid IDs
- ✅ Handle network errors
- ✅ Sequential requests

---

### 4️⃣ **Toggle/Get Favourite Usecases** (`toggle_and_get_favourite_usecase_test.dart`)

**Purpose**: Test favorite movie management

#### ToggleFavourite Tests:
```dart
// Toggle adds/removes from favorites
when(() => mockMovieRepository.toggleFavorite(movie))
    .thenAnswer((_) async => {});
    
await toggleFavourite(movie);
```

#### GetFavourite Tests:
```dart
// Retrieve all favorite movies
when(() => mockMovieRepository.getFavoriteMovies())
    .thenAnswer((_) async => favoritesList);
    
final result = await getFavourite(NoParams());
expect(result.length, 2); // Returns 2 favorites
```

---

## 🗄️ REPOSITORY TESTS

### **MovieRepositoriesImpl** (`movie_repository_impl_test.dart`)

**Purpose**: Test data layer - repository implementation

### Test Categories:

#### 📥 **GetPopularMovies Tests**
```dart
// ✅ Success case
when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
final result = await repository.getPopularMovies(1);
expect(result, isA<MovieResponse>());

// ❌ Network error
when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
expect(
  () => repository.getPopularMovies(1),
  throwsA(isA<NetworkFailure>()),
);
```

**Key Points**:
- Checks network connectivity **before** remote call
- Throws `NetworkFailure` when offline
- Throws `ServerFailure` on server errors
- Converts API response to domain entities

#### 📝 **SearchMovies Tests**
- Verify search returns correct results
- Handle empty results gracefully
- Convert DioException to domain failures

#### ❤️ **Favorite Management Tests**
```dart
// Toggle favorite (local storage)
await repository.toggleFavorite(movie);
verify(() => mockLocalDataSource.toggleFavorite(any())).called(1);

// Get favorites
final favorites = await repository.getFavoriteMovies();
expect(favorites, isNotEmpty);
```

#### 🔄 **Integration Tests**
```dart
// Multiple operations in sequence
final movies = await repository.getPopularMovies(1);
final details = await repository.getMovieDetails(1);
await repository.toggleFavorite(details);
final favorites = await repository.getFavoriteMovies();

expect(movies.movies, isNotEmpty);
expect(details, isNotNull);
expect(favorites, isNotEmpty);
```

---

## 🔲 BLOC TESTS

### **MovieBloc** (`movie_bloc_test.dart`)

**Purpose**: Test state management and business logic

### Using `bloc_test` Package:

```dart
blocTest<MovieBloc, MovieState>(
  'description of what should happen',
  build: () {
    // Setup: Configure mocks before returning bloc
    when(() => mockGetPopularMovies(any()))
        .thenAnswer((_) async => tMovieResponse);
    return movieBloc;
  },
  act: (bloc) {
    // Act: Trigger events or actions
    bloc.add(FetchPopularMovies());
  },
  expect: () => [
    // Expect: Define expected state transitions
    MovieLoading(),
    isA<MovieLoaded>(),
  ],
);
```

### Test Categories:

#### 1️⃣ **FetchPopularMovies Event**

```dart
// ✅ Success - should emit Loading then Loaded
blocTest<MovieBloc, MovieState>(
  'should emit [MovieLoading, MovieLoaded] when successful',
  build: () => movieBloc,
  act: (bloc) => bloc.add(FetchPopularMovies()),
  expect: () => [
    MovieLoading(),      // First: Show loading spinner
    isA<MovieLoaded>(),  // Then: Show movies
  ],
);

// ❌ Network error - should emit Loading then Error
blocTest<MovieBloc, MovieState>(
  'should emit MovieError on NetworkFailure',
  build: () {
    when(() => mockGetPopularMovies(any()))
        .thenThrow(NetworkFailure());
    return movieBloc;
  },
  act: (bloc) => bloc.add(FetchPopularMovies()),
  expect: () => [
    MovieLoading(),
    isA<MovieError>()
        .having((s) => s.message, 'message', contains('connection')),
  ],
);
```

**Key Assertions**:
- `isA<Type>()`: Check state type
- `.having()`: Verify specific properties
- `contains()`: Check substring

#### 2️⃣ **LoadMoreMovies Event** (Pagination)

```dart
// ✅ Should append new movies
seed: () => MovieLoaded(
  movies: [movie1],        // Initial 1 movie
  hasReachedMax: false,
),
act: (bloc) => bloc.add(LoadMoreMovies()),
// Expect: [movie1, movie2] after appending

// 🛑 Should NOT load if already fetching
test('should not execute if already fetching', () {
  movieBloc.isFetching = true;
  movieBloc.add(LoadMoreMovies());
  // No state change expected
});

// 🏁 Should NOT load if reached max pages
seed: () => MovieLoaded(
  movies: [movie1],
  hasReachedMax: true,     // Already at last page
),
act: (bloc) => bloc.add(LoadMoreMovies()),
// Expect: No change
```

#### 3️⃣ **RefreshMovies Event**

```dart
// ✅ Should reset to page 1 and reload
act: (bloc) {
  bloc.page = PageParams(page: 5);  // Currently on page 5
  bloc.add(RefreshMovies());         // Refresh
},
verify: (bloc) {
  expect(bloc.page.page, 1);        // Back to page 1
},

// ❌ Error handling
blocTest<MovieBloc, MovieState>(
  'should emit error on refresh failure',
  build: () {
    when(() => mockGetPopularMovies(any()))
        .thenThrow(Exception('Error'));
    return movieBloc;
  },
  act: (bloc) => bloc.add(RefreshMovies()),
  expect: () => [
    isA<MovieError>()
        .having((s) => s.message, 'message', 'Failed to refresh'),
  ],
);
```

---

## 📊 Test Coverage Summary

| Component | Tests | Coverage |
|-----------|-------|----------|
| GetPopularMovies | 5 | ✅ Success, Pagination, Empty, Error, Multiple |
| SearchMovies | 6 | ✅ Search, Pagination, Empty, Special chars, Multiple, Error |
| GetMovieDetails | 6 | ✅ Details, ID passing, Invalid ID, Network Error, Sequential |
| Toggle/Get Favourite | 10 | ✅ Toggle, Get, Multiple, Empty, Integration |
| Repository | 12 | ✅ All data operations + integration |
| MovieBloc | 15 | ✅ Fetch, Load More, Refresh, Error, State Management |
| **TOTAL** | **54 tests** | **Complete coverage** |

---

## 🧩 Key Testing Patterns

### 1. **AAA Pattern (Arrange-Act-Assert)**
```dart
test('description', () {
  // 🔧 Arrange: Setup data and mocks
  when(() => mock.method()).thenAnswer(...);
  
  // 🎬 Act: Execute function
  final result = await function();
  
  // ✔️ Assert: Verify result
  expect(result, expected);
  
  // 🔍 Verify: Confirm mocks were called
  verify(() => mock.method()).called(1);
});
```

### 2. **Mocking with Mocktail**
```dart
// Create mock
class MockRepository extends Mock implements Repository {}

// Setup behavior
when(() => mockRepo.getMovies()).thenAnswer((_) async => movies);

// Verify calls
verify(() => mockRepo.getMovies()).called(1);
verifyNever(() => mockRepo.getMovies());
```

### 3. **State Verification (Bloc Tests)**
```dart
// Multiple matchers
expect: () => [
  isA<Loading>(),
  isA<Loaded>()
      .having((s) => s.items.length, 'length', greaterThan(0))
      .having((s) => s.total, 'total', 100),
],
```

### 4. **Error Testing**
```dart
// Test exception throwing
test('should throw', () {
  when(() => mock.method()).thenThrow(Exception());
  expect(() => function(), throwsException);
});

// Test specific exception type
expect(() => function(), throwsA(isA<NetworkFailure>()));
```

---

## 🚀 Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/usecases/get_popular_movies_usecase_test.dart

# Run tests matching pattern
flutter test --name "GetPopularMovies"

# Run with coverage
flutter test --coverage

# Run tests verbosely
flutter test -v
```

---

## 📚 Best Practices

✅ **DO**:
- Use descriptive test names
- Follow AAA pattern
- Mock external dependencies
- Test edge cases and errors
- Use `blocTest` for Bloc tests
- Verify mock calls
- Test one thing per test

❌ **DON'T**:
- Test implementation details
- Make actual API calls
- Skip error cases
- Write brittle tests
- Test multiple things in one test
- Use hard delays instead of async

---

## 🔗 Dependencies Used

```yaml
dev_dependencies:
  flutter_test:        # Basic testing
  mocktail: ^0.2.0    # Mocking library
  bloc_test: ^8.0.0   # Bloc testing utilities
```

---

## 💡 Common Assertions

```dart
// Value assertions
expect(value, 10);
expect(value, isNotNull);
expect(value, isEmpty);
expect(value, isNaN);
expect(value, isPositive);

// Collection assertions
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list.length, 5);
expect(list, contains(item));

// Type assertions
expect(value, isA<String>());
expect(value, isA<MovieLoaded>());

// String assertions
expect(text, contains('substring'));
expect(text, startsWith('start'));
expect(text, endsWith('end'));
expect(text, matches(RegExp('pattern')));
```

---

## 🎓 Summary

This test suite provides comprehensive coverage for:
- ✅ **Usecases**: Business logic isolation
- ✅ **Repositories**: Data layer integration  
- ✅ **Blocs**: State management & event handling

All tests use **Clean Architecture** principles with proper separation of concerns and maximum reusability through mocking.
