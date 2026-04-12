import 'package:flutter/widgets.dart';
import 'package:movie_explorer_app/core/util/usecase.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie_response.dart';
import 'package:movie_explorer_app/features/movie/domain/repositories/movie_repository.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';

class GetPopularMovies implements UseCase<MovieResponse, PageParams> {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  @override
  Future<MovieResponse> call(PageParams params) async {
    debugPrint("GetPopularMovies called with page: ${params.page}"); // ✅ debug log
    return await repository.getPopularMovies(params.page);
  }
}
