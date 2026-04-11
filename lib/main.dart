import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/home_screen.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

void main() async {
  // Ensure that the Flutter framework is initialized before loading environment variables
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // ✅ REGISTER ADAPTER
  Hive.registerAdapter(MovieModelAdapter());
  await Hive.deleteBoxFromDisk('favorites');

  final box = await Hive.openBox('favorites');
  // setup service locator for dependency injection
  // ✅ Pass box to DI
  await init(box);
  runApp(
    MaterialApp(
      home: BlocProvider(
        create: (_) => singleton<MovieBloc>(),
        child: const HomeScreen(),
      ),
    ),
  );
}
