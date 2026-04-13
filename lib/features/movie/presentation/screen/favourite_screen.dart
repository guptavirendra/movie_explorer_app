import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_cubit.dart';
import 'package:movie_explorer_app/features/movie/presentation/cubit/favourites_state.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) {
          if (state is FavouritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavouritesError) {
            return Center(child: Text(state.message));
          }

          if (state is FavouritesEmpty) {
            return const Center(child: Text('No favourites yet!'));
          }

          if (state is FavouritesLoaded) {
            return ListView.builder(
              itemCount: state.movies.length,
              itemBuilder: (_, index) {
                final movie = state.movies[index];

                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  title: Text(movie.title),
                  subtitle: Text("⭐ ${movie.rating}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<FavouritesCubit>().removeFavorite(movie);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
