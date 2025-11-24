import 'package:flutter/material.dart';
import 'package:movie_app/core/app_strings.dart';
import 'package:movie_app/ui/widgets/movie_card.dart';
import 'package:movie_app/viewmodels/search_view_model.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.searchMovies)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: vm.onQueryChanged,
                ),
              ),
              if (vm.loading) const LinearProgressIndicator(),
              Expanded(
                child: (vm.results.isEmpty && !vm.loading)
                    ? const Center(child: Text(AppStrings.noMoviesFound))
                    : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: vm.results.length,
                  itemBuilder: (_, i) {
                    final m = vm.results[i];
                    return MovieCard(
                      movie: m,
                      onTap: () => Navigator.pushNamed(
                          context, '/details/${m.id}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
