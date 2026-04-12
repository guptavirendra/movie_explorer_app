# Movie Explorer App

A Flutter app built with Clean Architecture and MVVM principles to browse popular movies, view details, search titles, and save favorites offline.

## 🚀 Project Overview

Movie Explorer connects to The Movie Database (TMDb) public API and provides:
- Home screen with paginated popular movies
- Movie details view with overview, rating, release date, and favorite toggle
- Search screen with debounce and infinite scroll
- Offline favorites persisted locally using Hive
- Centralized routing and dependency injection via GetIt

## 🧩 Architecture

The app follows a Clean Architecture + MVVM structure:
- `presentation` — UI, Bloc/Cubit state management, screens
- `domain` — entities, repository contracts, use cases
- `data` — API client, remote/local data sources, repository implementation
- `core` — shared utilities, network interceptors, routing, Hive service
- `injections` — dependency registration with GetIt

## 🔧 Dependencies

Key packages used in this project:
- `dio` for networking
- `flutter_bloc` / `bloc` for state management
- `get_it` for dependency injection
- `hive_flutter` / `hive` for local persistence
- `flutter_dotenv` for secure environment configuration
- `cached_network_image` for movie posters
- `connectivity_plus` for connectivity awareness

## ⚙️ Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Create a local `.env` file in the project root using `.env.example`:
   ```bash
   cp .env.example .env
   ```
3. Add your TMDb API key to `.env`:
   ```dotenv
   API_KEY=YOUR_TMDB_API_KEY
   API_BASE_URL=https://api.themoviedb.org/3
   ```
4. Run the app:
   ```bash
   flutter run
   ```

> Note: `.env` is excluded from version control. Do not commit your actual API key.

## 🧪 Running Tests

Run all tests:
```bash
flutter test
```

Run a specific folder:
```bash
flutter test test/usecases/
flutter test test/repositories/
flutter test test/blocs/
```

Run an individual test file:
```bash
flutter test test/usecases/get_popular_movies_usecase_test.dart
```

Generate coverage:
```bash
flutter test --coverage
```

## 📁 Key Files

- `lib/main.dart` — app entry point
- `lib/injections/service_locator.dart` — GetIt registration
- `lib/core/routes/app_routes.dart` — centralized routing
- `lib/core/network/dio_client.dart` — Dio configuration
- `lib/features/movie/domain/usecases` — business rules
- `lib/features/movie/data/repositories/movie_repositories_impl.dart` — repository implementation
- `lib/features/movie/presentation/bloc` and `cubit` — state management
- `lib/features/movie/presentation/screen` — UI screens

## ✅ What’s Fixed

- Removed `.env` from `pubspec.yaml` asset bundling
- Added `.env.example` with placeholder values
- Replaced default README with assignment-specific documentation

## 📌 Notes

- Home screen uses lazy loading and pull-to-refresh.
- Search screen debounces API calls before searching.
- Favorites are stored using Hive and loaded offline.
- Routing and arguments are handled centrally through `AppRoutes`.
