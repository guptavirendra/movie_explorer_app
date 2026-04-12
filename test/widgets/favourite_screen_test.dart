import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/get_favourite.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/toggle_favourite.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/favourite_screen.dart';

class MockGetFavourite extends Mock implements GetFavourite {}

class MockToggleFavourite extends Mock implements ToggleFavourite {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getIt.reset(dispose: true);
  });

  testWidgets('FavouriteScreen renders favorite list without exceptions',
      (WidgetTester tester) async {
    final mockGetFavourite = MockGetFavourite();
    final mockToggleFavourite = MockToggleFavourite();

    final movieModel = MovieModel(
      id: 1,
      title: 'The Matrix',
      overview: 'A hacker discovers reality is a simulation.',
      posterPath: '/matrix.jpg',
      rating: 8.7,
      releaseDate: '1999-03-31',
    );

    when(() => mockGetFavourite(any()))
        .thenAnswer((_) async => [movieModel.toEntity()]);

    getIt.registerLazySingleton<FavouritesCubit>(() => FavouritesCubit(
          getFavorites: mockGetFavourite,
          toggleFavorite: mockToggleFavourite,
        ));

    await tester.pumpWidget(
      MaterialApp(home: FavouriteScreen()),
    );

    // First frame builds the screen and creates the cubit.
    await tester.pump();

    // Allow the async loadFavorites call to complete and update state.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('The Matrix'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
