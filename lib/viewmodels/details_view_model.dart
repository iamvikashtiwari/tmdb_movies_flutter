import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:movie_app/imports.dart';

class DetailsViewModel extends ChangeNotifier {
  final MovieRepository repo;

  DetailsViewModel({required this.repo});

  MovieDetailModel? detail;
  bool loading = true;
  bool bookmarked = false;
  bool online = true;

  final BaseCacheManager cacheManager =
  CacheManager(Config('movieCache', stalePeriod: const Duration(days: 30)));

  Future<void> loadDetails(int movieId) async {
    loading = true;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    online = connectivity != ConnectivityResult.none;

    detail = await repo.getDetails(movieId);

    final flag = await repo.hive.getBookmarkFlag(movieId);
    bookmarked = flag == 1;

    if (online && detail?.posterPath != null) {
      final url = Constants.imageBase + detail!.posterPath!;
      final file = await cacheManager.downloadFile(url);
      await repo.hive.upsertMovie(
        MovieModel(
          id: detail!.id,
          title: detail!.title,
          posterPath: detail!.posterPath,
          localImagePath: file.file.path,
          overview: detail!.overview,
        ),
      );
    }

    loading = false;
    notifyListeners();
  }

  Future<void> toggleBookmark(int movieId) async {
    bookmarked = !bookmarked;
    await repo.setBookmark(movieId, bookmarked);
    notifyListeners();
  }

  String? getPosterPath() {
    if (online && detail?.posterPath != null) {
      return Constants.imageBase + detail!.posterPath!;
    } else if (detail?.localImagePath != null) {
      return detail!.localImagePath!;
    }
    return null;
  }
}
