import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';
  static const String _dynamicKey = 'dynamic_color';
  static const String _presetKey = 'theme_preset';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _useDynamicColor = false;
  bool get useDynamicColor => _useDynamicColor;

  AppThemePreset _preset = AppThemePreset.klasik;
  AppThemePreset get preset => _preset;

  ThemeData get currentLightTheme => AppTheme.lightThemeForPreset(_preset);
  ThemeData get currentDarkTheme => AppTheme.darkThemeForPreset(_preset);

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
    final storedPreset = prefs.getString(_presetKey);
    _preset = AppThemePreset.values.firstWhere(
      (p) => p.name == storedPreset,
      orElse: () => AppThemePreset.klasik,
    );
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

  Future<void> setPreset(AppThemePreset value) async {
    if (_preset == value) return;
    _preset = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetKey, value.name);
  }
}
