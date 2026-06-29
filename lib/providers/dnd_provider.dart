import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/services/dnd_service.dart';

/// Namaz vaktinde otomatik sessiz (DND) modu.
class DndProvider extends ChangeNotifier {
  final DndService _service = DndService();

  static const String _enabledKey = 'dnd_enabled';
  static const String _durationKey = 'dnd_duration';

  bool _enabled = false;
  int _durationMinutes = 15;
  bool _hasAccess = false;
  Timer? _restoreTimer;

  bool get enabled => _enabled;
  int get durationMinutes => _durationMinutes;
  bool get hasAccess => _hasAccess;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _durationMinutes = prefs.getInt(_durationKey) ?? 15;
    _hasAccess = await _service.hasAccess();
    notifyListeners();
  }

  Future<void> refreshAccess() async {
    _hasAccess = await _service.hasAccess();
    notifyListeners();
  }

  Future<void> openSettings() => _service.openSettings();

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (value) await refreshAccess();
  }

  Future<void> setDuration(int minutes) async {
    _durationMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, minutes);
  }

  /// Bir namaz vakti girdiğinde çağrılır → süreli sessize alır.
  /// (Uygulama açık/süreçteyken çalışır; tam arka plan için native alarm gerekir.)
  Future<void> handlePrayerEntered() async {
    if (!_enabled) return;
    if (!await _service.hasAccess()) return;

    final ok = await _service.setSilent(true);
    if (!ok) return;

    _restoreTimer?.cancel();
    _restoreTimer = Timer(Duration(minutes: _durationMinutes), () {
      _service.setSilent(false);
    });
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    super.dispose();
  }
}
