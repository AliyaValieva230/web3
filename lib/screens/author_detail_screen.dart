import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/author_list_notifier.dart';

class AuthorDetailScreen extends StatelessWidget {
  final int id;
  const AuthorDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final author = notifier.result.items.firstWhere(
      (a) => a.id == id,
      orElse: () => throw StateError('Автор не найден'),
    );
    return Scaffold(
      appBar: AppBar(title: Text(author.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: ${author.firstName}'),
            Text('Фамилия: ${author.lastName}'),
            if (author.middleName != null) Text('Отчество: ${author.middleName}'),
            Text('Страна: ${author.country}'),
          ],
        ),
      ),
    );
  }
}