import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../state/author_list_notifier.dart';
import '../models/author.dart';

class AuthorFormScreen extends StatefulWidget {
  final int? id;
  const AuthorFormScreen({super.key, this.id});
  bool get isEditing => id != null;
  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _countryController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadData();
    for (final c in [_firstNameController, _lastNameController, _middleNameController, _countryController]) {
      c.addListener(() => _hasChanges = true);
    }
  }

  Future<void> _loadData() async {
    final author = await context.read<AuthorListNotifier>().findById(widget.id!);
    if (author != null) {
      setState(() {
        _firstNameController.text = author.firstName;
        _lastNameController.text = author.lastName;
        _middleNameController.text = author.middleName ?? '';
        _countryController.text = author.country;
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_firstNameController, _lastNameController, _middleNameController, _countryController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final author = Author(
      id: widget.id ?? 0,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
      country: _countryController.text.trim(),
      deletedAt: null,
    );
    await context.read<AuthorListNotifier>().save(author);
    if (mounted) context.go('/authors');
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
        appBar: AppBar(title: Text(widget.isEditing ? 'Редактировать автора' : 'Новый автор')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Фамилия', border: OutlineInputBorder()),
                  validator: V.combine([V.required(), V.length(min: 2, max: 100)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()),
                  validator: V.combine([V.required(), V.length(min: 2, max: 100)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(labelText: 'Отчество', border: OutlineInputBorder()),
                  validator: V.length(max: 100),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Страна', border: OutlineInputBorder()),
                  validator: V.combine([V.required(), V.length(max: 100)]),
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