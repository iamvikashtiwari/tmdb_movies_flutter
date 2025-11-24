import 'package:hive/hive.dart';
import '../data/models.dart';

class HiveService {
  static const String moviesBox = 'moviesBox';
  Box? _box;

  Future<Box> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(moviesBox);
    return _box!;
  }

  Future<void> upsertMovie(MovieModel m) async {
    final box = await _ensureBox();
    await box.put(
      m.id.toString(),
      {
        'id': m.id,
        'title': m.title,
        'posterPath': m.posterPath,
        'localImagePath': m.localImagePath,
        'overview': m.overview,
        'releaseDate': m.releaseDate,
        'voteAverage': m.voteAverage,
        'bookmarked': await getBookmarkFlag(m.id) ?? 0,
        'runtime': m.runtime,
        'revenue': m.revenue,
        'fetchedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<MovieModel>> getAllMovies() async {
    final box = await _ensureBox();
    final values = box.values.cast<Map>().toList();
    return values.map((r) => _mapToMovie(r)).toList();
  }

  Future<List<MovieModel>> searchLocal(String q) async {
    final box = await _ensureBox();
    final values = box.values.cast<Map>()
        .where((r) => (r['title'] as String).toLowerCase().contains(q.toLowerCase()))
        .toList();
    return values.map((r) => _mapToMovie(r)).toList();
  }

  Future<void> setBookmark(int id, bool flag) async {
    final box = await _ensureBox();
    final key = id.toString();
    Map<String, dynamic>? entry = (box.get(key) as Map?)?.cast<String, dynamic>();
    if (entry != null) {
      entry['bookmarked'] = flag ? 1 : 0;
      await box.put(key, entry);
    } else {
      await box.put(key, {
        'id': id,
        'title': '(Unknown Title)',
        'posterPath': null,
        'localImagePath': null,
        'overview': null,
        'releaseDate': null,
        'voteAverage': null,
        'bookmarked': flag ? 1 : 0,
        'runtime': null,
        'revenue': null,
        'fetchedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<List<MovieModel>> getBookmarked() async {
    final box = await _ensureBox();
    final values = box.values.cast<Map>()
        .where((r) => (r['bookmarked'] ?? 0) == 1)
        .toList();
    return values.map((r) => _mapToMovie(r)).toList();
  }

  Future<int?> getBookmarkFlag(int id) async {
    final box = await _ensureBox();
    final entry = box.get(id.toString()) as Map?;
    return entry?['bookmarked'] as int?;
  }

  MovieModel _mapToMovie(Map r) {
    return MovieModel(
      id: r['id'] as int,
      title: r['title'] as String,
      posterPath: r['posterPath'] as String?,
      localImagePath: r['localImagePath'] as String?,
      overview: r['overview'] as String?,
      releaseDate: r['releaseDate'] as String?,
      voteAverage: r['voteAverage'] != null
          ? (r['voteAverage'] as num).toDouble()
          : null,
      runtime: r['runtime'] as int?,
      revenue: r['revenue'] as int?,
    );
  }

  Future<Box> getBox() async => _ensureBox();
}
