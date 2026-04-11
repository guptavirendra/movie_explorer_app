import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_state.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/favourite_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/screen/movie_details_screen.dart';
import 'package:movie_explorer_app/features/movie/presentation/widget/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(FetchPopularMovies());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<MovieBloc>().add(LoadMoreMovies());
      }
    });
  }

  Future<void> _onRefresh() async {
    context.read<MovieBloc>().add(RefreshMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movies"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouriteScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MovieError) {
              return Center(child: Text(state.message));
            }

            if (state is MovieLoaded) {
              final bloc = context.read<MovieBloc>();

              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      itemCount: state.movies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                          ),
                      itemBuilder: (_, index) {
                        final movie = state.movies[index];

                        return MovieCard(
                          movie: movie,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsScreen(
                                  movieDetailsParams: MovieDetailsParams(
                                    movie.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ✅ SHOW ONLY DURING LOAD MORE
                  if (bloc.isFetching)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
