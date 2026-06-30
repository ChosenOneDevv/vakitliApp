import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/hadith.dart';

class HadithService {
  List<Hadith>? _cachedHadiths;

  Future<List<Hadith>> loadHadiths() async {
    if (_cachedHadiths != null) return _cachedHadiths!;

    final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedHadiths = jsonList
          .map((item) => Hadith.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _cachedHadiths = [];
    }
    return _cachedHadiths!;
  }

  Future<Hadith?> getDailyHadith() async {
    final hadiths = await loadHadiths();
    if (hadiths.isEmpty) return null;

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % hadiths.length;
    return hadiths[index];
  }

  Future<Hadith?> getHadithById(int id) async {
    final hadiths = await loadHadiths();
    try {
      return hadiths.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Aktif namaz vaktine göre hadis döner. Gün + vakit indeksiyle döngüsel seçim.
  Future<Hadith?> getHadithForPrayer(String prayerKey) async {
    final hadiths = await loadHadiths();
    if (hadiths.isEmpty) return null;
    final prayerIndex = const {
      'fajr': 0,
      'sunrise': 1,
      'dhuhr': 2,
      'asr': 3,
      'maghrib': 4,
      'isha': 5,
    }[prayerKey] ??
        0;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (dayOfYear * 6 + prayerIndex) % hadiths.length;
    return hadiths[index];
  }
}
