import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tutulan oruç günlerini ('yyyy-MM-dd') SharedPreferences'da saklar.
class FastingService {
  static const String _key = 'fasting_days';

  static String dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Set<String> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(days.toList()));
  }
}
