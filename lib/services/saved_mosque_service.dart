import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedMosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const SavedMosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SavedMosque.fromJson(Map<String, dynamic> j) => SavedMosque(
        id: j['id'] as String,
        name: j['name'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );
}

class SavedMosqueService {
  static const String _key = 'saved_mosques';

  Future<List<SavedMosque>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedMosque.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<SavedMosque> mosques) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(mosques.map((m) => m.toJson()).toList()));
  }

  Future<void> add(SavedMosque mosque) async {
    final list = await loadAll();
    if (list.any((m) => m.id == mosque.id)) return;
    list.add(mosque);
    await saveAll(list);
  }

  Future<void> remove(String id) async {
    final list = await loadAll();
    list.removeWhere((m) => m.id == id);
    await saveAll(list);
  }

  Future<bool> isSaved(String id) async {
    final list = await loadAll();
    return list.any((m) => m.id == id);
  }
}
