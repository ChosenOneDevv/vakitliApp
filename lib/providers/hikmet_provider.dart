import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/hikmet.dart';
import 'package:vakitli/services/hikmet_service.dart';

class HikmetProvider extends ChangeNotifier {
  final HikmetService _service = HikmetService();

  static const String _favKey = 'hikmet_favorites';

  List<Hikmet> _all = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isFavorite(int id) => _favoriteIds.contains(id);

  List<Hikmet> get filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where((h) =>
            h.text.toLowerCase().contains(q) ||
            h.author.toLowerCase().contains(q) ||
            h.topic.toLowerCase().contains(q))
        .toList();
  }

  List<Hikmet> get favorites =>
      _all.where((h) => _favoriteIds.contains(h.id)).toList();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _all = await _service.loadHikmetler();
      await _loadFavorites();
      _error = null;
    } catch (e) {
      _error = 'Hikmetler yüklenirken hata oluştu.';
    }
    _isLoading = false;
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
    final jsonStr = prefs.getString(_favKey);
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
    await prefs.setString(_favKey, jsonEncode(_favoriteIds.toList()));
  }
}
