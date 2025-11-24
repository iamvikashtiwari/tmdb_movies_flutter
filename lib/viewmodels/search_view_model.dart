import 'dart:async';
import 'package:movie_app/imports.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository repo;
  Timer? _debounce;

  List<MovieModel> results = [];
  bool loading = false;
  bool online = true;

  SearchViewModel(this.repo);

  void onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      loading = true;
      notifyListeners();

      final conn = await Connectivity().checkConnectivity();
      online = conn != ConnectivityResult.none;

      results = await repo.search(q.trim());

      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
