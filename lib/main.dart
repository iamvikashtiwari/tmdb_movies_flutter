import 'dart:async';
import 'package:movie_app/imports.dart';
import 'package:movie_app/ui/screens/details_screen.dart';
import 'package:movie_app/ui/screens/home_screen.dart';
import 'package:movie_app/viewmodels/bookmark_view_model.dart';
import 'package:movie_app/viewmodels/home_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (if you have HiveType models)
  // Hive.registerAdapter(MovieModelAdapter());
  // Hive.registerAdapter(MovieDetailModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final RetrofitClient api = RetrofitClient();
  final HiveService hive = HiveService();
  late final MovieRepository repo;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    repo = MovieRepository(api: api, hive: hive);
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null &&
            uri.scheme == 'tmdbapp' &&
            uri.host == 'movie' &&
            uri.pathSegments.isNotEmpty) {
          final id = int.tryParse(uri.pathSegments[0]);
          if (id != null) {
            navigatorKey.currentState?.pushNamed('/details/$id');
          }
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MovieRepository>(create: (_) => repo),
        ChangeNotifierProvider<HomeViewModel>(
            create: (_) => HomeViewModel(repo)),
        ChangeNotifierProvider<BookmarkViewModel>(
            create: (_) => BookmarkViewModel(repo)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: AppStrings.appTitle,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');
          final segments = uri.pathSegments.where((e) => e.isNotEmpty).toList();

          if (segments.isEmpty) {
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          }

          if (segments.length == 2 && segments[0] == 'details') {
            final id = int.tryParse(segments[1]);
            if (id != null) {
              return MaterialPageRoute(
                  builder: (_) => DetailsScreen(movieId: id));
            }
          }

          // fallback
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        },
      ),
    );
  }
}
