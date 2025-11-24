import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:movie_app/imports.dart';

class MovieRepository {
  final RetrofitClient api;
  final HiveService hive;
  final BaseCacheManager cacheManager = CacheManager(
    Config('movieCache', stalePeriod: const Duration(days: 30)),
  );

  MovieRepository({required this.api, required this.hive});

  Future<bool> _isOnline() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  Future<List<MovieModel>> getTrending() async {
    if (await _isOnline()) {
      try {
        final list = await api.getTrending();
        for (var m in list) {
          String? localPath;

          // Download & cache the poster image
          if (m.posterPath != null) {
            final file = await cacheManager.downloadFile(Constants.imageBase + m.posterPath!);
            localPath = file.file.path;
          }

          final movie = MovieModel(
            id: m.id,
            title: m.title,
            posterPath: m.posterPath,
            localImagePath: localPath,
            overview: m.overview,
            releaseDate: m.releaseDate,
            voteAverage: m.voteAverage,
            runtime: m.runtime,
            revenue: m.revenue,
          );

          await hive.upsertMovie(movie);
        }
        return list;
      } catch (_) {
        return hive.getAllMovies();
      }
    } else {
      return hive.getAllMovies();
    }
  }


  Future<List<MovieModel>> getNowPlaying() async {
    if (await _isOnline()) {
      try {
        final list = await api.getNowPlaying();
        for (var m in list) {
          String? localPath;
          if (m.posterPath != null) {
            final file =
            await cacheManager.downloadFile(Constants.imageBase + m.posterPath!);
            localPath = file.file.path;
          }
          m.localImagePath = localPath;
          await hive.upsertMovie(m);
        }
        return list;
      } catch (_) {
        return hive.getAllMovies();
      }
    } else {
      return hive.getAllMovies();
    }
  }

  Future<List<MovieModel>> search(String q) async {
    if (await _isOnline()) {
      try {
        final list = await api.search(q);
        for (var m in list) {
          String? localPath;
          if (m.posterPath != null) {
            final file =
            await cacheManager.downloadFile(Constants.imageBase + m.posterPath!);
            localPath = file.file.path;
          }
          m.localImagePath = localPath;
          await hive.upsertMovie(m);
        }
        return list;
      } catch (_) {
        return hive.searchLocal(q);
      }
    } else {
      return hive.searchLocal(q);
    }
  }

  Future<void> setBookmark(int id, bool flag) => hive.setBookmark(id, flag);
  Future<List<MovieModel>> getBookmarked() => hive.getBookmarked();

  Future<MovieDetailModel?> getDetails(int id) async {
    if (await _isOnline()) {
      try {
        final detail = await api.getDetails(id);
        if (detail != null) {
          String? localPath;
          if (detail.posterPath != null) {
            final file = await cacheManager
                .downloadFile(Constants.imageBase + detail.posterPath!);
            localPath = file.file.path;
          }
          final movie = MovieModel(
            id: detail.id,
            title: detail.title,
            posterPath: detail.posterPath,
            localImagePath: localPath,
            overview: detail.overview,
            runtime: detail.runtime,
            revenue: detail.revenue,
          );
          await hive.upsertMovie(movie);
        }
        return detail;
      } catch (_) {
        return _getDetailsOffline(id);
      }
    } else {
      return _getDetailsOffline(id);
    }
  }

  Future<MovieDetailModel?> _getDetailsOffline(int id) async {
    final movies = await hive.getAllMovies();
    MovieModel? entry;
    try {
      entry = movies.firstWhere((m) => m.id == id);
    } catch (e) {
      entry = null;
    }

    if (entry == null) return null;

    return MovieDetailModel(
      id: entry.id,
      title: entry.title,
      posterPath: entry.posterPath,
      localImagePath: entry.localImagePath,
      overview: entry.overview,
      runtime: entry.runtime,
      revenue: entry.revenue,
    );
  }

}
