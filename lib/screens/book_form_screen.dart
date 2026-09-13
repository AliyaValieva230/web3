import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../state/book_list_notifier.dart';
import '../state/author_list_notifier.dart';
import '../state/genre_list_notifier.dart';
import '../state/publisher_list_notifier.dart';
import '../models/book.dart';

class BookFormScreen extends StatefulWidget {
  final int? id;
  const BookFormScreen({super.key, this.id});
  bool get isEditing => id != null;
  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();
  final _pagesController = TextEditingController();
  final _copiesTotalController = TextEditingController();
  final _copiesAvailableController = TextEditingController();
  int? _publisherId;
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  Map<String, String> _serverErrors = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadData();
    for (final c in [_titleController, _isbnController, _yearController, _pagesController, _copiesTotalController, _copiesAvailableController]) {
      c.addListener(() => _hasChanges = true);
    }
  }

  Future<void> _loadData() async {
    final book = await context.read<BookListNotifier>().findById(widget.id!);
    if (book != null) {
      setState(() {
        _titleController.text = book.title;
        _isbnController.text = book.isbn;
        _yearController.text = book.year.toString();
        _pagesController.text = book.pages.toString();
        _copiesTotalController.text = book.copiesTotal.toString();
        _copiesAvailableController.text = book.copiesAvailable.toString();
        _publisherId = book.publisherId;
        _authorIds = List.from(book.authorIds);
        _genreIds = List.from(book.genreIds);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_titleController, _isbnController, _yearController, _pagesController, _copiesTotalController, _copiesAvailableController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _showDiscardDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text('Покинуть форму без сохранения?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Покинуть')),
        ],
      ),
    );
    return confirm ?? false;
  }

  Widget _buildMultiSelect<T>({
    required String label,
    required List<T> items,
    required List<int> selectedIds,
    required ValueChanged<List<int>> onChanged,
    required int Function(T) idGetter,
    required String Function(T) labelGetter,
  }) {
    return FormField<List<int>>(
      initialValue: selectedIds,
      validator: (v) => (v == null || v.isEmpty) ? 'Выберите хотя бы один' : null,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final id = idGetter(item);
              final selected = field.value!.contains(id);
              return FilterChip(
                label: Text(labelGetter(item)),
                selected: selected,
                onSelected: (_) {
                  final next = List<int>.from(field.value!);
                  if (selected) next.remove(id);
                  else next.add(id);
                  field.didChange(next);
                  onChanged(next);
                  setState(() {});
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = {});
    if (!_formKey.currentState!.validate()) return;
    final notifier = context.read<BookListNotifier>();
    if (!notifier.isIsbnUnique(_isbnController.text, excludeId: widget.id)) {
      setState(() => _serverErrors['isbn'] = 'ISBN уже используется');
      _formKey.currentState!.validate();
      return;
    }
    final book = Book(
      id: widget.id ?? 0,
      title: _titleController.text.trim(),
      isbn: _isbnController.text.trim(),
      year: int.parse(_yearController.text),
      pages: int.parse(_pagesController.text),
      publisherId: _publisherId!,
      authorIds: _authorIds,
      genreIds: _genreIds,
      copiesTotal: int.parse(_copiesTotalController.text),
      copiesAvailable: int.parse(_copiesAvailableController.text),
      deletedAt: null,
    );
    try {
      await notifier.save(book);
      if (mounted) context.go('/books');
    } catch (e) {
      setState(() => _serverErrors['general'] = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authors = context.watch<AuthorListNotifier>().result.items;
    final genres = context.watch<GenreListNotifier>().result.items;
    final publishers = context.watch<PublisherListNotifier>().result.items;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final ok = await _showDiscardDialog();
          if (ok) {
            _hasChanges = false;
            if (mounted) Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.isEditing ? 'Редактировать книгу' : 'Новая книга')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                  validator: V.combine([V.required(), V.length(min: 2, max: 255)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(labelText: 'ISBN', border: const OutlineInputBorder(), errorText: _serverErrors['isbn']),
                  validator: V.combine([V.required(), V.isbn()]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Год', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: V.combine([V.required(), V.integer(min: 1450, max: 2100)]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pagesController,
                  decoration: const InputDecoration(labelText: 'Страниц', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: V.combine([V.required(), V.positiveInt()]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _copiesTotalController,
                  decoration: const InputDecoration(labelText: 'Всего экз.', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: V.combine([V.required(), V.positiveInt()]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _copiesAvailableController,
                  decoration: const InputDecoration(labelText: 'Доступно экз.', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: V.combine([V.required(), V.positiveInt()]),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _publisherId,
                  decoration: const InputDecoration(labelText: 'Издательство', border: OutlineInputBorder()),
                  items: publishers.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _publisherId = v),
                  validator: (v) => v == null ? 'Выберите издательство' : null,
                ),
                const SizedBox(height: 12),
                _buildMultiSelect(
                  label: 'Авторы',
                  items: authors,
                  selectedIds: _authorIds,
                  onChanged: (v) => setState(() => _authorIds = v),
                  idGetter: (a) => a.id,
                  labelGetter: (a) => a.fullName,
                ),
                const SizedBox(height: 12),
                _buildMultiSelect(
                  label: 'Жанры',
                  items: genres,
                  selectedIds: _genreIds,
                  onChanged: (v) => setState(() => _genreIds = v),
                  idGetter: (g) => g.id,
                  labelGetter: (g) => g.name,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.isEditing ? 'Обновить' : 'Создать'),
                ),
                if (_serverErrors.containsKey('general'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_serverErrors['general']!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}