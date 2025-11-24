import 'dart:io';
import 'package:movie_app/imports.dart';
import 'package:movie_app/viewmodels/bookmark_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkViewModel>(context, listen: false).load();
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bookmarksMovies)),
      body: Consumer<BookmarkViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.saved.isEmpty) {
            return const Center(child: Text(AppStrings.noBookmarks));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.56,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: vm.saved.length,
            itemBuilder: (_, i) {
              final movie = vm.saved[i];

              Widget img;
              if (movie.localImagePath != null &&
                  File(movie.localImagePath!).existsSync()) {
                img = Image.file(
                  File(movie.localImagePath!),
                  fit: BoxFit.cover,
                );
              } else {
                img = CachedNetworkImage(
                  imageUrl: Constants.imageBase + movie.posterPath!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 80),
                );
              }

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/details/${movie.id}',
                  );

                  if (result != null) {
                    vm.load();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: img),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
