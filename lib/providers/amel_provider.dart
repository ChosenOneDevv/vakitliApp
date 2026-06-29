import 'package:flutter/material.dart';
import 'package:vakitli/models/amel_entry.dart';
import 'package:vakitli/services/amel_service.dart';

class AmelProvider extends ChangeNotifier {
  final AmelService _service = AmelService();

  List<AmelEntry> _all = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<AmelEntry> forDay(DateTime date) {
    final key = _dateKey(date);
    return _all.where((e) => e.date == key).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  List<AmelEntry> get today => forDay(DateTime.now());

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _all = await _service.loadAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required String text,
    required AmelCategory category,
    int count = 1,
  }) async {
    final entry = AmelEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _dateKey(DateTime.now()),
      text: text.trim(),
      category: category,
      count: count,
    );
    _all.insert(0, entry);
    notifyListeners();
    await _service.saveAll(_all);
  }

  Future<void> deleteEntry(String id) async {
    _all.removeWhere((e) => e.id == id);
    notifyListeners();
    await _service.saveAll(_all);
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
