import 'package:movie_app/imports.dart';
import 'package:movie_app/ui/screens/bookmarks_screen.dart';
import 'package:movie_app/ui/screens/search_screen.dart';
import 'package:movie_app/ui/widgets/movie_card.dart';
import 'package:movie_app/viewmodels/bookmark_view_model.dart';
import 'package:movie_app/viewmodels/home_view_model.dart';
import 'package:movie_app/viewmodels/search_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
    final bookmarkVM = Provider.of<BookmarkViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.wait([
        homeVM.load(),
        bookmarkVM.load(),
      ]);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final repo = Provider.of<MovieRepository>(context, listen: false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => SearchViewModel(repo),
                    child: const SearchScreen(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: bookmarkVM,
                    child: const BookmarksScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (_, vm, __) {
          // Show partial UI if some data is loaded
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([vm.load(), bookmarkVM.load()]);
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text(AppStrings.trending,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: vm.trending.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.trending.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final m = vm.trending[i];
                            return MovieCard(
                              movie: m,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/details/${m.id}',
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                const Text(AppStrings.nowPlaying,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: vm.nowPlaying.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.nowPlaying.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final m = vm.nowPlaying[i];
                            return MovieCard(
                              movie: m,
                              small: true,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/details/${m.id}',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
