import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/dua.dart';
import 'package:vakitli/services/dua_service.dart';

class DuaProvider extends ChangeNotifier {
  final DuaService _service = DuaService();

  static const String _favoritesKey = 'dua_favorites';
  static const String allCategory = 'Tümü';
  static const String favCategory = 'Favoriler';

  List<Dua> _allDuas = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;

  String _selectedCategory = allCategory;
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  /// Filtre çubuğu için kategoriler: Tümü + Favoriler + veri kategorileri.
  List<String> get categories {
    final set = <String>{};
    for (final dua in _allDuas) {
      set.add(dua.category);
    }
    return [allCategory, favCategory, ...set];
  }

  /// Kategori + arama uygulanmış liste.
  List<Dua> get filteredDuas {
    Iterable<Dua> list = _allDuas;

    if (_selectedCategory == favCategory) {
      list = list.where((d) => _favoriteIds.contains(d.id));
    } else if (_selectedCategory != allCategory) {
      list = list.where((d) => d.category == _selectedCategory);
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((d) =>
          d.title.toLowerCase().contains(q) ||
          d.meaning.toLowerCase().contains(q) ||
          d.transliteration.toLowerCase().contains(q));
    }

    return list.toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allDuas = await _service.loadDuas();
      await _loadFavorites();
      _error = null;
    } catch (e) {
      _error = 'Dualar yüklenirken hata oluştu.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void search(String query) {
    _query = query.trim();
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_favoritesKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> ids = jsonDecode(jsonStr);
        _favoriteIds = ids.map((e) => e as int).toSet();
      } catch (_) {
        _favoriteIds = {};
      }
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(_favoriteIds.toList()));
  }
}
