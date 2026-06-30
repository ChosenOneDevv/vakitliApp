import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/dnd_log_entry.dart';

/// Camide sessize alma geçmişini saklar (Faz 25 — son [_maxEntries] kayıt).
class DndLogService {
  static const String _key = 'dnd_log';
  static const int _maxEntries = 20;

  Future<List<DndLogEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DndLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Yeni kayıt ekler; en yeni başta, en fazla [_maxEntries] tutulur.
  Future<void> add(DndLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await load();
    entries.insert(0, entry);
    final trimmed =
        entries.length > _maxEntries ? entries.sublist(0, _maxEntries) : entries;
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
