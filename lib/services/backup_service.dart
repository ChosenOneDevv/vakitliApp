import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tüm yerel veriyi (SharedPreferences) JSON olarak dışa/içe aktarır.
class BackupService {
  Future<String> export() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      final v = prefs.get(key);
      String type;
      if (v is bool) {
        type = 'bool';
      } else if (v is int) {
        type = 'int';
      } else if (v is double) {
        type = 'double';
      } else if (v is List<String>) {
        type = 'list';
      } else {
        type = 'string';
      }
      data[key] = {'t': type, 'v': v};
    }
    return jsonEncode({'app': 'vakitli', 'version': 1, 'data': data});
  }

  /// JSON yedeği geri yükler. Başarılıysa true.
  Future<bool> import(String jsonStr) async {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (decoded['app'] != 'vakitli') return false;
      final data = decoded['data'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      for (final entry in data.entries) {
        final spec = entry.value as Map<String, dynamic>;
        final t = spec['t'] as String;
        final v = spec['v'];
        switch (t) {
          case 'bool':
            await prefs.setBool(entry.key, v as bool);
          case 'int':
            await prefs.setInt(entry.key, v as int);
          case 'double':
            await prefs.setDouble(entry.key, (v as num).toDouble());
          case 'list':
            await prefs.setStringList(
                entry.key, (v as List).cast<String>());
          default:
            await prefs.setString(entry.key, v as String);
        }
      }
      return true;
    } catch (e) {
      debugPrint('BackupService.import hata: $e');
      return false;
    }
  }
}
