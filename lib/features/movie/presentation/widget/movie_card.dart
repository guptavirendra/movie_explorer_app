import 'package:flutter/material.dart';
import 'package:movie_explorer_app/features/movie/domain/entities/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            Image.network(
              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
              height: 150,
              fit: BoxFit.cover,
            ),
            Text(movie.title),
            //Text("⭐ ${movie.rating}"),
          ],
        ),
      ),
    );
  }
}
