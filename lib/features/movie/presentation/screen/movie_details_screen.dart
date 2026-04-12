import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_state.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieDetailsParams movieDetailsParams;

  const MovieDetailsScreen({super.key, required this.movieDetailsParams});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          singleton<MovieDetailsCubit>()..fetchMovieDetails(movieDetailsParams),
      child: Scaffold(
        appBar: AppBar(title: const Text("Movie Details")),
        body: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MovieDetailsError) {
              return Center(child: Text(state.message));
            }

            if (state is MovieDetailsLoaded) {
              final movie = state.movie;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backdrop Image
                    CachedNetworkImage(
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,

                      imageUrl:
                          "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔥 TITLE + FAVORITE BUTTON
                          BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
                            builder: (context, state) {
                              final cubit = context.read<MovieDetailsCubit>();

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// Title
                                  Expanded(
                                    child: Text(
                                      movie.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// ❤️ Favorite Button
                                  IconButton(
                                    icon: Icon(
                                      cubit.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      cubit.toggleFav(movie);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          /// Rating
                          Text(
                            "⭐ ${movie.rating}",
                          ), // Placeholder, replace with actual rating if available

                          const SizedBox(height: 8),

                          /// Release Date
                          Text("Release: ${movie.releaseDate}"),

                          const SizedBox(height: 12),

                          /// Overview Title
                          const Text(
                            "Overview",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Overview Text
                          Text(movie.overview),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
