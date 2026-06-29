import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';
  static const String _dynamicKey = 'dynamic_color';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _useDynamicColor = false;
  bool get useDynamicColor => _useDynamicColor;

  String get label => switch (_themeMode) {
        ThemeMode.light => 'Açık',
        ThemeMode.dark => 'Koyu',
        ThemeMode.system => 'Sistem',
      };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    _themeMode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _useDynamicColor = prefs.getBool(_dynamicKey) ?? false;
    notifyListeners();
  }

  Future<void> setDynamicColor(bool value) async {
    if (_useDynamicColor == value) return;
    _useDynamicColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicKey, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
