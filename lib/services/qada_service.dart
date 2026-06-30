import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Kaza namazı borç sayaçlarını SharedPreferences'da saklar.
class QadaService {
  static const String _key = 'qada_counts';

  /// Takip edilen namazlar (5 farz + Vitir).
  static const List<String> prayerKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
    'witr',
  ];

  static const Map<String, String> prayerNames = {
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
    'witr': 'Vitir',
  };

  Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final result = {for (final k in prayerKeys) k: 0};
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        for (final k in prayerKeys) {
          result[k] = (decoded[k] as int?) ?? 0;
        }
      } catch (_) {
        // Bozuk cache → sıfır sayaçlarla devam et
      }
    }
    return result;
  }

  Future<void> save(Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(counts));
  }
}
