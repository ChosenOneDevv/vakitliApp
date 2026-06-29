import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama dili: null = sistem, 'tr', 'en'.
class LocaleProvider extends ChangeNotifier {
  static const String _key = 'app_locale';

  Locale? _locale;
  Locale? get locale => _locale;

  String get code => _locale?.languageCode ?? 'system';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'tr' || stored == 'en') {
      _locale = Locale(stored!);
    }
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = (code == 'tr' || code == 'en') ? Locale(code) : null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (_locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, code);
    }
  }
}
