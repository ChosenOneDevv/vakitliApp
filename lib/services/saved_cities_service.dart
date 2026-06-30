import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Çoklu şehir takibi için kaydedilen şehir (ad + koordinat).
class SavedCity {
  final String name;
  final double latitude;
  final double longitude;

  const SavedCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SavedCity.fromJson(Map<String, dynamic> j) => SavedCity(
        name: j['name'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );
}

/// Kaydedilen şehirleri SharedPreferences'ta saklar (anahtarsız, lokal).
class SavedCitiesService {
  static const String _key = 'tracked_cities';

  Future<List<SavedCity>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedCity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SavedCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(cities.map((c) => c.toJson()).toList()));
  }

  Future<void> add(SavedCity city) async {
    final list = await loadAll();
    if (list.any((c) => c.name == city.name)) return;
    list.add(city);
    await _saveAll(list);
  }

  Future<void> remove(String name) async {
    final list = await loadAll();
    list.removeWhere((c) => c.name == name);
    await _saveAll(list);
  }
}
