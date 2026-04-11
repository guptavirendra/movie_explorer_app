import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
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
                  return Center(child: Text(state.message));
                }

                if (state is SearchLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.movies.length,
                    itemBuilder: (_, index) {
                      final movie = state.movies[index];

                      return ListTile(
                        leading: movie.posterPath.isNotEmpty
                            ? Image.network(
                                "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.movie),
                              )
                            : const Icon(Icons.movie),
                        title: Text(movie.title),
                        subtitle: Text("⭐ ${movie.rating}"),
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
