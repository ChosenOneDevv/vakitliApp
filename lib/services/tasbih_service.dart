import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/tasbih_profile.dart';

/// Tesbih profillerini ve aktif profili SharedPreferences'da saklar.
class TasbihService {
  static const String _profilesKey = 'tasbih_profiles';
  static const String _activeKey = 'tasbih_active_id';

  /// İlk açılışta kullanılacak varsayılan profiller.
  static List<TasbihProfile> defaultProfiles() => [
        TasbihProfile(id: 1, name: 'Sübhanallah', target: 33),
        TasbihProfile(id: 2, name: 'Elhamdülillah', target: 33),
        TasbihProfile(id: 3, name: 'Allahu Ekber', target: 34),
      ];

  Future<List<TasbihProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profilesKey);
    if (jsonStr == null) return defaultProfiles();

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final profiles = list
          .map((e) => TasbihProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      return profiles.isEmpty ? defaultProfiles() : profiles;
    } catch (_) {
      return defaultProfiles();
    }
  }

  Future<void> saveProfiles(List<TasbihProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  Future<int?> loadActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeKey);
  }

  Future<void> saveActiveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeKey, id);
  }
}
