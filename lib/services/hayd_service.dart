import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/flow_entry.dart';
import 'package:vakitli/models/hayd_record.dart';

class HaydService {
  static const String _key = 'hayd_records';
  static const String _flowKey = 'hayd_flow_entries';
  static const String _madhhabKey = 'hayd_madhhab';
  static const String _habitualKey = 'hayd_habitual_days';

  Future<List<HaydRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => HaydRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<HaydRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }

  // --- Günlük akıntı kayıtları (Faz 24b) ---

  Future<List<FlowEntry>> loadFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_flowKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => FlowEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFlow(List<FlowEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _flowKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  // --- Mezhep (Faz 24a) ---

  Future<int> loadMadhhabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_madhhabKey) ?? 0; // 0 = Hanefi
  }

  Future<void> saveMadhhabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_madhhabKey, index);
  }

  // --- Âdet (alışılmış hayız süresi, mutâde) ---

  Future<int?> loadHabitualDays() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_habitualKey);
    return (v == null || v <= 0) ? null : v;
  }

  Future<void> saveHabitualDays(int? days) async {
    final prefs = await SharedPreferences.getInstance();
    if (days == null || days <= 0) {
      await prefs.remove(_habitualKey);
    } else {
      await prefs.setInt(_habitualKey, days);
    }
  }
}
