import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/page_result.dart';
import '../repositories/book_repository.dart';
import '../core/debounce.dart';

enum LoadStatus { idle, loading, success, error }

class BookListNotifier extends ChangeNotifier {
  final BookRepository _repo;
  BookListNotifier(this._repo);

  String _search = '';
  int? _genreId, _publisherId, _yearFrom, _yearTo;
  String _sortField = 'title';
  bool _sortAscending = true;
  int _page = 1, _size = 10;
  bool _includeDeleted = false;

  LoadStatus _status = LoadStatus.idle;
  String? _error;
  PageResult<Book> _result = PageResult.empty();
  final Set<int> _selected = {};
  final Debouncer _debouncer = Debouncer();

  LoadStatus get status => _status;
  String? get error => _error;
  PageResult<Book> get result => _result;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;
  String get search => _search;
  int? get genreId => _genreId;
  int? get publisherId => _publisherId;
  int? get yearFrom => _yearFrom;
  int? get yearTo => _yearTo;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  int get page => _page;
  int get size => _size;
  bool get includeDeleted => _includeDeleted;

  void updateSearch(String v) { _search = v; _page = 1; _debouncer.call(_load); }
  void updateFilters({int? genreId, int? publisherId, int? yearFrom, int? yearTo, bool? includeDeleted}) {
    if (genreId != null) _genreId = genreId;
    if (publisherId != null) _publisherId = publisherId;
    if (yearFrom != null) _yearFrom = yearFrom;
    if (yearTo != null) _yearTo = yearTo;
    if (includeDeleted != null) _includeDeleted = includeDeleted;
    _page = 1;
    _load();
  }
  void sortBy(String f) {
    if (_sortField == f) _sortAscending = !_sortAscending;
    else { _sortField = f; _sortAscending = true; }
    _page = 1;
    _load();
  }
  void goToPage(int p) { _page = p; _load(); }
  void setSize(int s) { _size = s; _page = 1; _load(); }
  void load() => _load();

  Future<void> _load() async {
    _status = LoadStatus.loading;
    _error = null;
    _selected.clear();
    notifyListeners();
    try {
      _result = await _repo.find(
        search: _search, genreId: _genreId, publisherId: _publisherId,
        yearFrom: _yearFrom, yearTo: _yearTo, sortField: _sortField,
        sortAscending: _sortAscending, page: _page, size: _size,
        includeDeleted: _includeDeleted,
      );
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Ошибка: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) _selected.remove(id);
    else _selected.add(id);
    notifyListeners();
  }
  Future<void> deleteSelected() async {
    if (_selected.isEmpty) return;
    await _repo.deleteMany(_selected.toList());
    _selected.clear();
    await _load();
  }
  Future<void> softDeleteSelected() async {
    if (_selected.isEmpty) return;
    for (final id in _selected.toList()) await _repo.softDelete(id);
    _selected.clear();
    await _load();
  }
  Future<void> restoreSelected() async {
    if (_selected.isEmpty) return;
    for (final id in _selected.toList()) await _repo.restore(id);
    _selected.clear();
    await _load();
  }
  Future<void> hardDeleteSelected() async {
    if (_selected.isEmpty) return;
    for (final id in _selected.toList()) await _repo.hardDelete(id);
    _selected.clear();
    await _load();
  }
  Future<Book?> findById(int id) => _repo.findById(id);
  Future<void> save(Book book) async {
    if (book.id == 0) await _repo.create(book);
    else await _repo.update(book);
    await _load();
  }
  bool isIsbnUnique(String isbn, {int? excludeId}) {
    return (_repo as dynamic).isIsbnUnique(isbn, excludeId: excludeId);
  }
  @override
  void dispose() { _debouncer.dispose(); super.dispose(); }
}