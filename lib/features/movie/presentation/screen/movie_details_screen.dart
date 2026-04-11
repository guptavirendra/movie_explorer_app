import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/movie_details_state.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => singleton<MovieDetailsCubit>()..fetchDetails(movieId),
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
                    Image.network(
                      "https://image.tmdb.org/t/p/w500${movie.backdropPath}",
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Rating
                          Text(
                            "⭐ 1.0 ",
                          ), // Placeholder, replace with actual rating if available

                          const SizedBox(height: 8),

                          // Release Date
                          Text("Release: ${movie.releaseDate}"),

                          const SizedBox(height: 12),

                          // Overview
                          const Text(
                            "Overview",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

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
