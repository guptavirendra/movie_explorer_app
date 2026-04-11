import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injections/service_locator.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => singleton<SearchCubit>(),
      child: Scaffold(
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
                    return const Center(
                      child: Text("Start typing to search 🎬"),
                    );
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
                      itemCount: state.movies.length,
                      itemBuilder: (_, index) {
                        final movie = state.movies[index];

                        return ListTile(
                          leading: Image.network(
                            "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                            width: 50,
                            fit: BoxFit.cover,
                          ),
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
      ),
    );
  }
}
