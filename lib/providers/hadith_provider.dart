import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/hadith.dart';
import 'package:vakitli/services/hadith_service.dart';
import 'package:vakitli/services/widget_service.dart';

class HadithProvider extends ChangeNotifier {
  final HadithService _hadithService = HadithService();

  Hadith? _dailyHadith;
  List<Hadith> _allHadiths = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;

  static const String _favoritesKey = 'hadith_favorites';

  Hadith? get dailyHadith => _dailyHadith;
  List<Hadith> get allHadiths => _allHadiths;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  List<Hadith> get favoriteHadiths =>
      _allHadiths.where((h) => _favoriteIds.contains(h.id)).toList();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allHadiths = await _hadithService.loadHadiths();
      _dailyHadith = await _hadithService.getDailyHadith();
      await _loadFavorites();
      _error = null;
      if (_dailyHadith != null) {
        WidgetService.updateHadith(
          text: _dailyHadith!.text,
          source: _dailyHadith!.source,
        );
      }
    } catch (e) {
      _error = 'Hadisler yüklenirken hata oluştu.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(int hadithId) async {
    if (_favoriteIds.contains(hadithId)) {
      _favoriteIds.remove(hadithId);
    } else {
      _favoriteIds.add(hadithId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_favoritesKey);
    if (jsonStr != null) {
      final List<dynamic> ids = jsonDecode(jsonStr);
      _favoriteIds = ids.map((e) => e as int).toSet();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(_favoriteIds.toList()));
  }
}
