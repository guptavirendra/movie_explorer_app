import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/routes/navigation_service.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_bloc.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_event.dart';
import 'package:movie_explorer_app/features/movie/presentation/block/movie_state.dart';
import 'package:movie_explorer_app/features/movie/presentation/widget/movie_card.dart';

class HomeScreen extends StatefulWidget {
  final NavigationService navigationService;

  const HomeScreen({super.key, required this.navigationService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  late StreamSubscription connectivitySub;

  bool hasInternet = true;
  bool _loadMoreTriggered = false;

  @override
  void initState() {
    super.initState();

    connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final isNowConnected = !result.contains(ConnectivityResult.none);

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
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.reverse) {
      return;
    }

    final isNearBottom = _scrollController.position.extentAfter < 300;

    if (isNearBottom && !_loadMoreTriggered) {
      _loadMoreTriggered = true;
      context.read<MovieBloc>().add(LoadMoreMovies());
    }

    if (!isNearBottom) {
      _loadMoreTriggered = false;
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Movies"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              widget.navigationService.goToSearch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              widget.navigationService.goToFavourites();
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
                        context.read<MovieBloc>().add(FetchPopularMovies());
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is MovieLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      cacheExtent: 300,
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
                            widget.navigationService.goToMovieDetails(movie.id);
                          },
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore)
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
