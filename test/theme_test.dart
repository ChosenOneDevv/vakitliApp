import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to system mode', () async {
    final provider = ThemeProvider();
    await provider.initialize();
    expect(provider.themeMode, ThemeMode.system);
    expect(provider.label, 'Sistem');
  });

  test('setThemeMode updates and labels', () async {
    final provider = ThemeProvider();
    await provider.initialize();
    await provider.setThemeMode(ThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.label, 'Koyu');
  });

  test('theme mode persists across instances', () async {
    final p1 = ThemeProvider();
    await p1.initialize();
    await p1.setThemeMode(ThemeMode.light);

    final p2 = ThemeProvider();
    await p2.initialize();
    expect(p2.themeMode, ThemeMode.light);
  });
}
