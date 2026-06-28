import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_log.dart';

/// Namaz takip kayıtlarını SharedPreferences'da saklar.
/// Depolama biçimi: { "yyyy-MM-dd": { "fajr": true, ... }, ... }
class TrackerService {
  static const String _key = 'prayer_logs';

  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<Map<String, PrayerLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};

    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return decoded.map(
      (date, value) => MapEntry(
        date,
        PrayerLog.fromJson(date, value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> saveLogs(Map<String, PrayerLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = logs.map((date, log) => MapEntry(date, log.toJson()));
    await prefs.setString(_key, jsonEncode(encoded));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
