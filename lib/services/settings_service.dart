import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama geneli ayar/veri işlemleri.
class SettingsService {
  /// Tüm yerel veriyi siler (favoriler, namaz takip, tesbih, alarm,
  /// konum, hesaplama metodu). Geri alınamaz.
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
