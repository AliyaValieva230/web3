import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/persistent_book_repository.dart';
import 'repositories/persistent_author_repository.dart';
import 'repositories/persistent_genre_repository.dart';
import 'repositories/persistent_publisher_repository.dart';
import 'repositories/persistent_reader_repository.dart';
import 'state/book_list_notifier.dart';
import 'state/author_list_notifier.dart';
import 'state/genre_list_notifier.dart';
import 'state/publisher_list_notifier.dart';
import 'state/reader_list_notifier.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PersistentBookRepository(prefs)),
        Provider(create: (_) => PersistentAuthorRepository(prefs)),
        Provider(create: (_) => PersistentGenreRepository(prefs)),
        Provider(create: (_) => PersistentPublisherRepository(prefs)),
        Provider(create: (_) => PersistentReaderRepository(prefs)),
        ChangeNotifierProvider(
          create: (ctx) => BookListNotifier(ctx.read<PersistentBookRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthorListNotifier(ctx.read<PersistentAuthorRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GenreListNotifier(ctx.read<PersistentGenreRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PublisherListNotifier(
            ctx.read<PersistentPublisherRepository>(),
            ctx.read<PersistentBookRepository>(),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ReaderListNotifier(ctx.read<PersistentReaderRepository>())..load(),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Библиотека',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}