import 'package:movie_app/imports.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository repo;

  List<MovieModel> trending = [];
  List<MovieModel> nowPlaying = [];
  bool loading = false;

  HomeViewModel(this.repo);

  Future<void> load() async {
    loading = true;
    notifyListeners();

    trending = await repo.getTrending();
    nowPlaying = await repo.getNowPlaying();

    loading = false;
    notifyListeners();
  }
}
