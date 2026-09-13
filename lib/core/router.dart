import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/book_list_screen.dart';
import '../screens/book_form_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/author_list_screen.dart';
import '../screens/author_form_screen.dart';
import '../screens/author_detail_screen.dart';
import '../screens/genre_list_screen.dart';
import '../screens/genre_form_screen.dart';
import '../screens/publisher_list_screen.dart';
import '../screens/publisher_form_screen.dart';
import '../screens/reader_list_screen.dart';
import '../screens/reader_form_screen.dart';
import '../screens/reader_detail_screen.dart';
import '../screens/not_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(path: '/books', builder: (_, __) => const BookListScreen()),
    GoRoute(path: '/books/new', builder: (_, __) => const BookFormScreen()),
    GoRoute(
      path: '/books/:id/edit',
      builder: (_, state) => BookFormScreen(id: int.tryParse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/books/:id',
      builder: (_, state) => BookDetailScreen(id: int.tryParse(state.pathParameters['id']!)!),
    ),
    GoRoute(path: '/authors', builder: (_, __) => const AuthorListScreen()),
    GoRoute(path: '/authors/new', builder: (_, __) => const AuthorFormScreen()),
    GoRoute(
      path: '/authors/:id/edit',
      builder: (_, state) => AuthorFormScreen(id: int.tryParse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/authors/:id',
      builder: (_, state) => AuthorDetailScreen(id: int.tryParse(state.pathParameters['id']!)!),
    ),
    GoRoute(path: '/genres', builder: (_, __) => const GenreListScreen()),
    GoRoute(path: '/genres/new', builder: (_, __) => const GenreFormScreen()),
    GoRoute(
      path: '/genres/:id/edit',
      builder: (_, state) => GenreFormScreen(id: int.tryParse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/publishers', builder: (_, __) => const PublisherListScreen()),
    GoRoute(path: '/publishers/new', builder: (_, __) => const PublisherFormScreen()),
    GoRoute(
      path: '/publishers/:id/edit',
      builder: (_, state) => PublisherFormScreen(id: int.tryParse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/readers', builder: (_, __) => const ReaderListScreen()),
    GoRoute(path: '/readers/new', builder: (_, __) => const ReaderFormScreen()),
    GoRoute(
      path: '/readers/:id/edit',
      builder: (_, state) => ReaderFormScreen(id: int.tryParse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/readers/:id',
      builder: (_, state) => ReaderDetailScreen(id: int.tryParse(state.pathParameters['id']!)!),
    ),
  ],
  errorBuilder: (_, state) => NotFoundScreen(location: state.uri.toString()),
);