import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/alarm_settings.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  static const String _ongoingKey = 'ongoing_notif_enabled';

  final AlarmSettings _alarmSettings = AlarmSettings();
  final NotificationService _notificationService = NotificationService();
  bool _initialized = false;
  bool _ongoingEnabled = false;

  // Son bilinen vakitler — ayar değişince yeniden kurmak için saklanır.
  PrayerTime? _todayPrayer;
  PrayerTime? _tomorrowPrayer;
  String? _lastScheduledKey;

  AlarmSettings get alarmSettings => _alarmSettings;
  bool get initialized => _initialized;
  bool get ongoingEnabled => _ongoingEnabled;

  Future<void> initialize() async {
    if (_initialized) return;
    await _notificationService.initialize();
    await _alarmSettings.load();
    final prefs = await SharedPreferences.getInstance();
    _ongoingEnabled = prefs.getBool(_ongoingKey) ?? false;
    _initialized = true;
    notifyListeners();
    // Vakitler init'ten önce gelmiş olabilir → varsa şimdi kur.
    await _reschedule();
    _lastScheduledKey = '${_todayPrayer?.date}|${_tomorrowPrayer?.date}';
    _updateOngoingNotif();
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

  /// Özel dakikayı ayarlar ve modu `custom` yapar.
  Future<void> setCustomMinutes(String prayerKey, int minutes) async {
    final clamped = minutes.clamp(0, 180);
    _alarmSettings.updateSetting(prayerKey,
        mode: AlarmMode.custom, customMinutes: clamped);
    await _alarmSettings.save();
    notifyListeners();
    await _reschedule();
  }

  /// Vakit gelince ezan sesi çalınsın mı.
  Future<void> setAlarmEzan(String prayerKey, bool value) async {
    _alarmSettings.updateSetting(prayerKey, useEzan: value);
    await _alarmSettings.save();
    notifyListeners();
    await _reschedule();
  }

  /// Önce alarmla birlikte vakitte de bildirim gönderilsin mi.
  Future<void> setAlsoOnTime(String prayerKey, bool value) async {
    _alarmSettings.updateSetting(prayerKey, alsoOnTime: value);
    await _alarmSettings.save();
    notifyListeners();
    await _reschedule();
  }

  /// Kalıcı bildirim (sonraki vakit göstergesi) aç/kapat.
  Future<void> toggleOngoing(bool value) async {
    _ongoingEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ongoingKey, value);
    notifyListeners();
    if (value) {
      _updateOngoingNotif();
    } else {
      await _notificationService.cancelOngoingNotification();
    }
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
    _updateOngoingNotif();
  }

  Future<void> _reschedule() async {
    if (!_initialized || _todayPrayer == null) return;
    await _notificationService.scheduleAllPrayerNotifications(
      prayerTime: _todayPrayer!,
      tomorrowPrayer: _tomorrowPrayer,
      alarmSettings: _alarmSettings,
    );
  }

  void _updateOngoingNotif() {
    if (!_ongoingEnabled || _todayPrayer == null) {
      _notificationService.cancelOngoingNotification();
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    PrayerEntry? nextEntry;
    DateTime? nextTime;

    for (final entry in _todayPrayer!.entries) {
      final t = entry.timeOn(today);
      if (t.isAfter(now)) {
        nextEntry = entry;
        nextTime = t;
        break;
      }
    }

    if (nextEntry == null && _tomorrowPrayer != null) {
      final tomorrow = today.add(const Duration(days: 1));
      nextEntry = _tomorrowPrayer!.entries.first;
      nextTime = nextEntry.timeOn(tomorrow);
    }

    if (nextEntry == null || nextTime == null) return;

    final diff = nextTime.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final remaining = h > 0 ? '$h sa $m dk' : '$m dk';

    _notificationService.showOngoingNotification(
      nextPrayerName: nextEntry.name,
      prayerTime: nextEntry.time,
      remaining: remaining,
    );
  }

  Future<void> cancelAll() async {
    await _notificationService.cancelAllNotifications();
  }
}
