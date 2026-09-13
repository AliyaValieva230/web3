import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/book_list_notifier.dart';

class BookDetailScreen extends StatelessWidget {
  final int id;
  const BookDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final book = notifier.result.items.firstWhere(
      (b) => b.id == id,
      orElse: () => throw StateError('Книга не найдена'),
    );
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ISBN: ${book.isbn}'),
            Text('Год: ${book.year}'),
            Text('Страниц: ${book.pages}'),
            Text('Издательство ID: ${book.publisherId}'),
            Text('Авторы: ${book.authorIds}'),
            Text('Жанры: ${book.genreIds}'),
            Text('Всего: ${book.copiesTotal}, Доступно: ${book.copiesAvailable}'),
          ],
        ),
      ),
    );
  }
}