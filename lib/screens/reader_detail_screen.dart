import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/reader_list_notifier.dart';

class ReaderDetailScreen extends StatelessWidget {
  final int id;
  const ReaderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ReaderListNotifier>();
    final reader = notifier.result.items.firstWhere(
      (r) => r.id == id,
      orElse: () => throw StateError('Читатель не найден'),
    );
    return Scaffold(
      appBar: AppBar(title: Text(reader.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Фамилия: ${reader.lastName}'),
            Text('Имя: ${reader.firstName}'),
            if (reader.middleName != null) Text('Отчество: ${reader.middleName}'),
            Text('Email: ${reader.email}'),
            const Divider(height: 32, thickness: 1),
            const Text('Билет', style: TextStyle(fontWeight: FontWeight.bold)),
            if (reader.card != null) ...[
              Text('Штрихкод: ${reader.card!.barcode}'),
              Text('Дата выдачи: ${reader.card!.issuedAt.toLocal().toIso8601String().split('T').first}'),
              Text('Дата окончания: ${reader.card!.expiresAt.toLocal().toIso8601String().split('T').first}'),
              Text('Статус: ${reader.card!.isActive ? 'Активен' : 'Неактивен'}'),
            ] else
              const Text('Билет не оформлен', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}