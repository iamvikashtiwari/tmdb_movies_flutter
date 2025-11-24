import 'dart:io';
import 'package:movie_app/imports.dart';
import 'package:movie_app/viewmodels/details_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailsScreen extends StatelessWidget {
  final int movieId;

  const DetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailsViewModel(
        repo: Provider.of<MovieRepository>(context, listen: false),
      )..loadDetails(movieId),
      child: Consumer<DetailsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading || vm.detail == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final movie = vm.detail!;

          Widget posterWidget;
          if (movie.localImagePath != null &&
              File(movie.localImagePath!).existsSync()) {
            posterWidget = Image.file(
              File(movie.localImagePath!),
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            );
          } else if (movie.posterPath != null) {
            posterWidget = CachedNetworkImage(
              imageUrl: Constants.imageBase + movie.posterPath!,
              placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 70),
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              cacheManager: vm.cacheManager,
            );
          } else {
            posterWidget = const Icon(Icons.image_not_supported,
                size: 70, color: Colors.grey);
          }

          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, vm.bookmarked);
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(movie.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, vm.bookmarked),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      vm.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () async {
                      await vm.toggleBookmark(movie.id);
                      if (vm.bookmarked &&
                          movie.posterPath != null &&
                          (movie.localImagePath == null ||
                              !File(movie.localImagePath!).existsSync())) {
                        final fileInfo = await vm.cacheManager.downloadFile(
                            Constants.imageBase + movie.posterPath!);

                        movie.localImagePath = fileInfo.file.path;
                        await vm.repo.hive.upsertMovie(movie);
                      }
                    },
                  )
                ],
              ),

              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: double.infinity, height: 350, child: posterWidget),
                    const SizedBox(height: 20),

                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(movie.overview ?? "No description"),

                    const SizedBox(height: 12),
                    if (movie.releaseDate != null)
                      Text("Release: ${movie.releaseDate}"),

                    if (movie.runtime != null)
                      Text("Runtime: ${movie.runtime} min"),

                    if (movie.revenue != null)
                      Text("Revenue: \$${movie.revenue}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
