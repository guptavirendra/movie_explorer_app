import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/routes/app_routes.dart';
import 'package:movie_explorer_app/features/movie/domain/usecases/params.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_state.dart';
import 'package:movie_explorer_app/features/movie/presentation/widget/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  late StreamSubscription connectivitySub;

  bool hasInternet = true;

  @override
  void initState() {
    super.initState();

    connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final isNowConnected = !result.contains(ConnectivityResult.none);

      // 🔥 only trigger when connection changes from OFF → ON
      if (!hasInternet && isNowConnected) {
        if (mounted) {
          final state = context.read<MovieBloc>().state;
          if (state is MovieError) {
            context.read<MovieBloc>().add(FetchPopularMovies());
          }
        }
      }

      hasInternet = isNowConnected;
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieBloc>().add(LoadMoreMovies());
    }
  }

  @override
  void dispose() {
    connectivitySub.cancel();
    _scrollController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.favourites);
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 60),
                    const SizedBox(height: 12),
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final bloc = context.read<MovieBloc>();
                        debugPrint("Retrying clicked..."); // ✅ debug log
                        //bloc.emit(MovieInitial()); // ✅ force state reset
                        bloc.add(FetchPopularMovies());
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
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
                            Navigator.pushNamed(
                              context,
                              AppRoutes.details,
                              arguments: MovieDetailsParams(movie.id),
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
