import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/amel_entry.dart';

class AmelService {
  static const String _key = 'amel_entries';

  Future<List<AmelEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    try {
      return AmelEntry.listFromJson(jsonStr);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<AmelEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AmelEntry.listToJson(entries));
  }
}
