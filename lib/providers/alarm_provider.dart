import 'package:flutter/material.dart';
import 'package:vakitli/models/alarm_settings.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  final AlarmSettings _alarmSettings = AlarmSettings();
  final NotificationService _notificationService = NotificationService();
  bool _initialized = false;

  // Son bilinen vakitler — ayar değişince yeniden kurmak için saklanır.
  PrayerTime? _todayPrayer;
  PrayerTime? _tomorrowPrayer;
  String? _lastScheduledKey;

  AlarmSettings get alarmSettings => _alarmSettings;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    await _notificationService.initialize();
    await _alarmSettings.load();
    _initialized = true;
    notifyListeners();
    // Vakitler init'ten önce gelmiş olabilir → varsa şimdi kur.
    await _reschedule();
    _lastScheduledKey = '${_todayPrayer?.date}|${_tomorrowPrayer?.date}';
  }

  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  PrayerAlarmSetting getSetting(String prayerKey) {
    return _alarmSettings.getSetting(prayerKey);
  }

  List<PrayerAlarmSetting> get allSettings => _alarmSettings.allSettings;

  Future<void> toggleAlarm(String prayerKey, bool enabled) async {
    _alarmSettings.updateSetting(prayerKey, enabled: enabled);
    await _alarmSettings.save();
    notifyListeners();
    await _reschedule();
  }

  Future<void> setAlarmMode(String prayerKey, AlarmMode mode) async {
    _alarmSettings.updateSetting(prayerKey, mode: mode);
    if (mode == AlarmMode.off) {
      _alarmSettings.updateSetting(prayerKey, enabled: false);
    }
    await _alarmSettings.save();
    notifyListeners();
    await _reschedule();
  }

  /// PrayerProvider güncellenince çağrılır (bugün + yarın vakitleri).
  Future<void> scheduleNotifications(
    PrayerTime? todayPrayer, {
    PrayerTime? tomorrowPrayer,
  }) async {
    _todayPrayer = todayPrayer;
    _tomorrowPrayer = tomorrowPrayer;

    final key = '${todayPrayer?.date}|${tomorrowPrayer?.date}';
    if (key == _lastScheduledKey) return; // aynı veri, tekrar kurma
    if (!_initialized || todayPrayer == null) return; // init sonrası kurulur
    _lastScheduledKey = key;
    await _reschedule();
  }

  Future<void> _reschedule() async {
    if (!_initialized || _todayPrayer == null) return;
    await _notificationService.scheduleAllPrayerNotifications(
      prayerTime: _todayPrayer!,
      tomorrowPrayer: _tomorrowPrayer,
      alarmSettings: _alarmSettings,
    );
  }

  Future<void> cancelAll() async {
    await _notificationService.cancelAllNotifications();
  }
}
