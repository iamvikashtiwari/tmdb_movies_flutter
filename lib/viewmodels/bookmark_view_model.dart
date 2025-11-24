import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:movie_app/imports.dart';

class BookmarkViewModel extends ChangeNotifier {
  final MovieRepository repo;
  List<MovieModel> saved = [];
  bool loading = false;

  final BaseCacheManager cacheManager =
  CacheManager(Config('bookmarkCache', stalePeriod: const Duration(days: 30)));

  BookmarkViewModel(this.repo);

  Future<void> load() async {
    loading = true;
    notifyListeners();

    saved = await repo.getBookmarked();

    for (var m in saved) {
      if (m.posterPath != null &&
          (m.localImagePath == null || !File(m.localImagePath!).existsSync())) {
        final fileInfo =
        await cacheManager.downloadFile(Constants.imageBase + m.posterPath!);
        m.localImagePath = fileInfo.file.path;
        await repo.hive.upsertMovie(m);
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<void> toggleBookmark(MovieModel m, bool flag) async {
    await repo.setBookmark(m.id, flag);

    if (flag) {
      if (!saved.any((e) => e.id == m.id)) {
        saved.add(m);

        if (m.posterPath != null) {
          final fileInfo =
          await cacheManager.downloadFile(Constants.imageBase + m.posterPath!);
          m.localImagePath = fileInfo.file.path;
          await repo.hive.upsertMovie(m);
        }
      }
    } else {
      saved.removeWhere((e) => e.id == m.id);
    }

    notifyListeners();
  }
}
