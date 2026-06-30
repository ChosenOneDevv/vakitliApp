import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/hadith.dart';
import 'package:vakitli/services/hadith_api_service.dart';
import 'package:vakitli/services/hadith_service.dart';
import 'package:vakitli/services/widget_service.dart';

class HadithProvider extends ChangeNotifier {
  final HadithService _hadithService = HadithService();
  final HadithApiService _apiService = HadithApiService();

  // ── Local (asset) hadiths ──
  Hadith? _dailyHadith;
  List<Hadith> _allHadiths = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;

  // ── API hadiths (HadeethEnc) ──
  List<HadithCategory> _categories = [];
  String? _selectedCategoryId;
  List<Hadith> _apiHadiths = [];
  int _apiPage = 1;
  int _apiLastPage = 1;
  bool _isApiLoading = false;

  static const String _favoritesKey = 'hadith_favorites';
  static const String _apiCacheKey = 'hadith_api_cache';

  // ── Getters ──
  Hadith? get dailyHadith => _dailyHadith;
  List<Hadith> get allHadiths => _allHadiths;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<HadithCategory> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Hadith> get apiHadiths => _apiHadiths;
  bool get isApiLoading => _isApiLoading;
  bool get hasMoreApiPages => _apiPage < _apiLastPage;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  List<Hadith> get favoriteHadiths {
    final all = [..._allHadiths, ..._apiHadiths];
    return all.where((h) => _favoriteIds.contains(h.id)).toList();
  }

  // ── Init ──
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

    // Categories load in background — don't block UI
    _loadCategories();
  }

  // ── API: categories ──
  Future<void> _loadCategories() async {
    final cats = await _apiService.fetchCategories();
    if (cats.isNotEmpty) {
      _categories = cats;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _apiHadiths = [];
    _apiPage = 1;
    _apiLastPage = 1;
    notifyListeners();
    await _fetchApiPage();
  }

  Future<void> loadNextPage() async {
    if (!hasMoreApiPages || _isApiLoading) return;
    _apiPage++;
    await _fetchApiPage();
  }

  Future<void> _fetchApiPage() async {
    final catId = _selectedCategoryId;
    if (catId == null) return;

    _isApiLoading = true;
    notifyListeners();

    final page = await _apiService.fetchHadiths(
      categoryId: catId,
      page: _apiPage,
      perPage: 20,
    );

    _apiLastPage = page.lastPage;
    final newHadiths = page.items.map(Hadith.fromApiJson).toList();
    _apiHadiths = [..._apiHadiths, ...newHadiths];

    // Cache current page
    await _saveApiCache(catId, _apiHadiths);

    _isApiLoading = false;
    notifyListeners();
  }

  // ── Favorites ──
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

  // ── API cache (per category) ──
  Future<void> _saveApiCache(String catId, List<Hadith> hadiths) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_apiCacheKey}_$catId';
      await prefs.setString(
        key,
        jsonEncode(hadiths.map((h) => h.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> loadApiCacheForCategory(String catId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('${_apiCacheKey}_$catId');
      if (raw != null) {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _apiHadiths = list.map(Hadith.fromJson).toList();
        notifyListeners();
      }
    } catch (_) {}
  }
}
