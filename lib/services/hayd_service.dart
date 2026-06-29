import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/hayd_record.dart';

class HaydService {
  static const String _key = 'hayd_records';

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
}
