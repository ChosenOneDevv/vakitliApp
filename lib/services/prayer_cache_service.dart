import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_time.dart';

/// Namaz vakitlerini offline kullanım için SharedPreferences'da saklar.
/// Anahtar: "lat_lng_yyyy-MM-dd" (koordinat 2 ondalığa yuvarlanmış).
class PrayerCacheService {
  static const String _key = 'prayer_cache';
  static const int _maxEntries = 45;

  static String buildKey(double lat, double lng, DateTime date) {
    final d =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}_$d';
  }

  Future<Map<String, dynamic>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  Future<PrayerTime?> get(double lat, double lng, DateTime date) async {
    final all = await _readAll();
    final entry = all[buildKey(lat, lng, date)];
    if (entry == null) return null;
    return PrayerTime.fromCacheJson(entry as Map<String, dynamic>);
  }

  Future<void> put(
      double lat, double lng, DateTime date, PrayerTime prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll();
    all[buildKey(lat, lng, date)] = prayer.toCacheJson();

    // Sınırı aşınca en eski (anahtar sıralı) kayıtları at.
    if (all.length > _maxEntries) {
      final keys = all.keys.toList()..sort();
      for (final k in keys.take(all.length - _maxEntries)) {
        all.remove(k);
      }
    }
    await prefs.setString(_key, jsonEncode(all));
  }

  /// Aylık listeyi toplu cache'ler.
  Future<void> putMany(
      double lat, double lng, List<PrayerTime> prayers) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll();
    for (final p in prayers) {
      // p.date "dd-MM-yyyy" Aladhan formatında gelir.
      final parts = p.date.split('-');
      if (parts.length != 3) continue;
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      all[buildKey(lat, lng, date)] = p.toCacheJson();
    }
    if (all.length > _maxEntries) {
      final keys = all.keys.toList()..sort();
      for (final k in keys.take(all.length - _maxEntries)) {
        all.remove(k);
      }
    }
    await prefs.setString(_key, jsonEncode(all));
  }
}
