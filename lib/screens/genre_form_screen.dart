import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../state/genre_list_notifier.dart';
import '../models/genre.dart';

class GenreFormScreen extends StatefulWidget {
  final int? id;
  const GenreFormScreen({super.key, this.id});
  bool get isEditing => id != null;
  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadData();
    _nameController.addListener(() => _hasChanges = true);
    _descController.addListener(() => _hasChanges = true);
  }

  Future<void> _loadData() async {
    final genre = await context.read<GenreListNotifier>().findById(widget.id!);
    if (genre != null) {
      setState(() {
        _nameController.text = genre.name;
        _descController.text = genre.description ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final genre = Genre(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      deletedAt: null,
    );
    await context.read<GenreListNotifier>().save(genre);
    if (mounted) context.go('/genres');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Несохранённые изменения'),
              content: const Text('Покинуть форму?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Покинуть')),
              ],
            ),
          );
          if (ok == true) {
            _hasChanges = false;
            if (mounted) Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.isEditing ? 'Редактировать жанр' : 'Новый жанр')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                  validator: V.combine([V.required(), V.length(min: 2, max: 100)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                  validator: V.length(max: 500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.isEditing ? 'Обновить' : 'Создать'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}