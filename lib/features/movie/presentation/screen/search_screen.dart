import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer_app/core/routes/navigation_service.dart';
import 'package:movie_explorer_app/injections/service_locator.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<SearchCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Movies")),
      body: Column(
        children: [
          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search movies...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                context.read<SearchCubit>().onQueryChanged(value);
              },
            ),
          ),

          // 📋 Results
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return const Center(child: Text("Start typing to search 🎬"));
                }

                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchEmpty) {
                  return const Center(child: Text("No results found 😔"));
                }

                if (state is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SearchCubit>().retry();
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.movies.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (index >= state.movies.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final movie = state.movies[index];

                      return ListTile(
                        leading: SizedBox(
                          width: 60,
                          height: 90,
                          child: movie.posterPath.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.movie),
                        ),
                        title: Text(movie.title),
                        subtitle: Text("⭐ ${movie.rating}"),
                        onTap: () {
                          singleton<NavigationService>().goToMovieDetails(
                            movie.id,
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
