import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Nafile/sünnet namaz takibini SharedPreferences'da saklar.
/// Biçim: { "yyyy-MM-dd": { "tahajjud": true, ... } }
class NafileService {
  static const String _key = 'nafile_logs';

  static const List<String> keys = [
    'tahajjud',
    'duha',
    'ishraq',
    'awwabin',
    'sunnah',
  ];

  static const Map<String, String> names = {
    'tahajjud': 'Teheccüd',
    'duha': 'Kuşluk (Duha)',
    'ishraq': 'İşrak',
    'awwabin': 'Evvâbîn',
    'sunnah': 'Revatib Sünnetler',
  };

  static String dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<Map<String, Map<String, bool>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return decoded.map((date, value) {
      final inner = (value as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as bool),
      );
      return MapEntry(date, inner);
    });
  }

  Future<void> save(Map<String, Map<String, bool>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(logs));
  }
}
