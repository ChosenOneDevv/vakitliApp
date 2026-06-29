import 'package:flutter/material.dart';
import 'package:vakitli/models/sunnah_lesson.dart';
import 'package:vakitli/services/sunnah_service.dart';

class SunnahProvider extends ChangeNotifier {
  final SunnahService _service = SunnahService();

  List<String> _categories = [];
  List<SunnahLesson> _lessons = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<String> get categories => _categories;
  List<SunnahLesson> get lessons => _lessons;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _service.loadCategories();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        _lessons = await _service.loadByCategory(_selectedCategory!);
      }
      _error = null;
    } catch (e) {
      _error = 'Dersler yüklenemedi.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();
    _lessons = await _service.loadByCategory(category);
    _isLoading = false;
    notifyListeners();
  }
}
