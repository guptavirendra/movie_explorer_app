import 'package:flutter/material.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

class GetPopularMovies implements UseCase<List<Movie>, PageParams> {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  @override
  Future<List<Movie>> call(PageParams params) async {
    return await repository.getPopularMovies(params.page);
  }
}