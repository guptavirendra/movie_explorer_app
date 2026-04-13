import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_explorer_app/core/routes/app_routes.dart';
import 'package:movie_explorer_app/core/routes/navigation_service.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

void main() async {
  // Ensure that the Flutter framework is initialized before loading environment variables
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  // Initialize the service locator and all dependencies
  await init();

  final router = AppRoutes.createRouter();
  singleton<NavigationService>().attachRouter(router);

  runApp(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
}
