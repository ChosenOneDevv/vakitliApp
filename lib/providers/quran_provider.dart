import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/quran_models.dart';
import 'package:vakitli/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _service = QuranService();

  List<Surah> _surahs = [];
  bool _isLoading = false;
  String? _error;

  List<QuranBookmark> _bookmarks = [];
  QuranBookmark? _lastRead;

  static const String _bookmarksKey = 'quran_bookmarks';
  static const String _lastReadKey = 'quran_last_read';

  List<Surah> get surahs => _surahs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<QuranBookmark> get bookmarks => _bookmarks;
  QuranBookmark? get lastRead => _lastRead;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _surahs = await _service.loadSurahs();
      await _loadPersistedData();
    } catch (e) {
      _error = 'Kuran yüklenemedi.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    final bmRaw = prefs.getString(_bookmarksKey);
    if (bmRaw != null) {
      try {
        final list = jsonDecode(bmRaw) as List;
        _bookmarks = list
            .map((e) => QuranBookmark.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    final lrRaw = prefs.getString(_lastReadKey);
    if (lrRaw != null) {
      try {
        _lastRead = QuranBookmark.fromJson(
            jsonDecode(lrRaw) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  Future<void> saveLastRead(int surah, int ayah) async {
    _lastRead = QuranBookmark(
        surah: surah, ayah: ayah, savedAt: DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadKey, jsonEncode(_lastRead!.toJson()));
    notifyListeners();
  }

  bool isBookmarked(int surah, int ayah) =>
      _bookmarks.any((b) => b.surah == surah && b.ayah == ayah);

  Future<void> toggleBookmark(int surah, int ayah) async {
    if (isBookmarked(surah, ayah)) {
      _bookmarks.removeWhere((b) => b.surah == surah && b.ayah == ayah);
    } else {
      _bookmarks.add(
          QuranBookmark(surah: surah, ayah: ayah, savedAt: DateTime.now()));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _bookmarksKey,
        jsonEncode(_bookmarks.map((b) => b.toJson()).toList()));
    notifyListeners();
  }

  List<Surah> search(String query) {
    if (query.trim().isEmpty) return _surahs;
    final q = query.trim().toLowerCase();
    return _surahs
        .where((s) =>
            s.turkishName.toLowerCase().contains(q) ||
            s.arabicName.contains(query) ||
            s.number.toString() == q)
        .toList();
  }
}
