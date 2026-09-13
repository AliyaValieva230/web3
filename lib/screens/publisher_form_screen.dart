import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../state/publisher_list_notifier.dart';
import '../models/publisher.dart';

class PublisherFormScreen extends StatefulWidget {
  final int? id;
  const PublisherFormScreen({super.key, this.id});
  bool get isEditing => id != null;
  @override
  State<PublisherFormScreen> createState() => _PublisherFormScreenState();
}

class _PublisherFormScreenState extends State<PublisherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadData();
    _nameController.addListener(() => _hasChanges = true);
    _addressController.addListener(() => _hasChanges = true);
  }

  Future<void> _loadData() async {
    final p = await context.read<PublisherListNotifier>().findById(widget.id!);
    if (p != null) {
      setState(() {
        _nameController.text = p.name;
        _addressController.text = p.address ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final publisher = Publisher(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      deletedAt: null,
    );
    await context.read<PublisherListNotifier>().save(publisher);
    if (mounted) context.go('/publishers');
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
        appBar: AppBar(title: Text(widget.isEditing ? 'Редактировать издательство' : 'Новое издательство')),
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
                  validator: V.combine([V.required(), V.length(min: 2, max: 200)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Адрес', border: OutlineInputBorder()),
                  validator: V.length(max: 300),
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