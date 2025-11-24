import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../data/models.dart';

class RetrofitClient {
  final Dio _dio;
  RetrofitClient({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: Constants.baseUrl,
        queryParameters: {"api_key": Constants.apiKey},
      ));

  Future<List<MovieModel>> getTrending() async {
    final resp = await _dio.get('/trending/movie/day');
    return _parseMovies(resp);
  }

  Future<List<MovieModel>> getNowPlaying() async {
    final resp = await _dio.get('/movie/now_playing');
    return _parseMovies(resp);
  }

  Future<List<MovieModel>> search(String query) async {
    final resp = await _dio.get('/search/movie', queryParameters: {"query": query});
    return _parseMovies(resp);
  }

  Future<MovieDetailModel?> getDetails(int id) async {
    final resp = await _dio.get('/movie/\$id'.replaceAll('\\$id', id.toString()));
    if (resp.statusCode == 200 && resp.data != null) return MovieDetailModel.fromJson(resp.data);
    return null;
  }

  List<MovieModel> _parseMovies(Response resp) {
    if (resp.statusCode == 200 && resp.data != null) {
      final results = resp.data['results'] as List<dynamic>;
      return results.map((e) => MovieModel.fromJson(e)).toList();
    }
    return [];
  }
}
