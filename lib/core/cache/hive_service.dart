import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_explorer_app/features/movie/data/models/movie_model.dart';

abstract class LocalStorageService {
  Future<void> init();
}

class HiveService implements LocalStorageService {
  static const favoritesBox = 'favorites';

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieModelAdapter());
    }

    await _safeOpenBox();
  }

  Future<void> _safeOpenBox() async {
    try {
      await Hive.openBox<MovieModel>(favoritesBox);
    } catch (_) {
      debugPrint("Failed to open Hive box"); // ✅ debug log
    }
  }

  Future<void> reset() async {
    await Hive.deleteFromDisk();
  }

  Box<MovieModel> get favoritesBoxInstance =>
      Hive.box<MovieModel>(favoritesBox);
}
