import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum AlarmMode {
  off,
  onTime,
  before5,
  before10,
  before15,
  before30,
  custom,
}

extension AlarmModeExtension on AlarmMode {
  String get label {
    switch (this) {
      case AlarmMode.off:
        return 'Kapalı';
      case AlarmMode.onTime:
        return 'Vaktinde';
      case AlarmMode.before5:
        return '5 dk önce';
      case AlarmMode.before10:
        return '10 dk önce';
      case AlarmMode.before15:
        return '15 dk önce';
      case AlarmMode.before30:
        return '30 dk önce';
      case AlarmMode.custom:
        return 'Özel';
    }
  }

  int get minutesBefore {
    switch (this) {
      case AlarmMode.before5:
        return 5;
      case AlarmMode.before10:
        return 10;
      case AlarmMode.before15:
        return 15;
      case AlarmMode.before30:
        return 30;
      case AlarmMode.off:
      case AlarmMode.onTime:
      case AlarmMode.custom:
        return 0;
    }
  }
}

class PrayerAlarmSetting {
  final String prayerKey;
  final String prayerName;
  bool enabled;
  AlarmMode mode;

  /// `mode == custom` için kullanıcı tanımlı dakika (vaktinden önce).
  int customMinutes;

  /// Bildirim sesi olarak ezan kullanılsın mı.
  bool useEzan;

  /// Önce alarm kuruluyken ayrıca vakitte de bildirim gönderilsin mi.
  bool alsoOnTime;

  PrayerAlarmSetting({
    required this.prayerKey,
    required this.prayerName,
    this.enabled = false,
    this.mode = AlarmMode.onTime,
    this.customMinutes = 10,
    this.useEzan = false,
    this.alsoOnTime = false,
  });

  /// Bildirimin vakitten kaç dk önce kurulacağı.
  int get effectiveMinutes =>
      mode == AlarmMode.custom ? customMinutes : mode.minutesBefore;

  /// UI'da gösterilecek etiket (özel için dakikayı yazar).
  String get displayLabel =>
      mode == AlarmMode.custom ? '$customMinutes dk önce' : mode.label;

  Map<String, dynamic> toJson() => {
        'prayerKey': prayerKey,
        'prayerName': prayerName,
        'enabled': enabled,
        'mode': mode.index,
        'customMinutes': customMinutes,
        'useEzan': useEzan,
        'alsoOnTime': alsoOnTime,
      };

  factory PrayerAlarmSetting.fromJson(Map<String, dynamic> json) {
    return PrayerAlarmSetting(
      prayerKey: json['prayerKey'] as String,
      prayerName: json['prayerName'] as String,
      enabled: json['enabled'] as bool? ?? false,
      mode: AlarmMode.values[json['mode'] as int? ?? 1],
      customMinutes: json['customMinutes'] as int? ?? 10,
      useEzan: json['useEzan'] as bool? ?? false,
      alsoOnTime: json['alsoOnTime'] as bool? ?? false,
    );
  }
}

class AlarmSettings {
  static const String _prefsKey = 'alarm_settings';

  final Map<String, PrayerAlarmSetting> _settings = {};

  static final List<PrayerAlarmSetting> defaults = [
    PrayerAlarmSetting(prayerKey: 'fajr', prayerName: 'İmsak'),
    PrayerAlarmSetting(prayerKey: 'sunrise', prayerName: 'Güneş'),
    PrayerAlarmSetting(prayerKey: 'dhuhr', prayerName: 'Öğle'),
    PrayerAlarmSetting(prayerKey: 'asr', prayerName: 'İkindi'),
    PrayerAlarmSetting(prayerKey: 'maghrib', prayerName: 'Akşam'),
    PrayerAlarmSetting(prayerKey: 'isha', prayerName: 'Yatsı'),
    PrayerAlarmSetting(prayerKey: 'tahajjud', prayerName: 'Teheccüd'),
  ];

  AlarmSettings() {
    for (final d in defaults) {
      _settings[d.prayerKey] = PrayerAlarmSetting(
        prayerKey: d.prayerKey,
        prayerName: d.prayerName,
      );
    }
  }

  PrayerAlarmSetting getSetting(String prayerKey) {
    return _settings[prayerKey] ??
        PrayerAlarmSetting(prayerKey: prayerKey, prayerName: prayerKey);
  }

  List<PrayerAlarmSetting> get allSettings => _settings.values.toList();

  void updateSetting(String prayerKey,
      {bool? enabled, AlarmMode? mode, int? customMinutes, bool? useEzan, bool? alsoOnTime}) {
    final setting = _settings[prayerKey];
    if (setting != null) {
      if (enabled != null) setting.enabled = enabled;
      if (mode != null) setting.mode = mode;
      if (customMinutes != null) setting.customMinutes = customMinutes;
      if (useEzan != null) setting.useEzan = useEzan;
      if (alsoOnTime != null) setting.alsoOnTime = alsoOnTime;
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _settings.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      for (final entry in data.entries) {
        _settings[entry.key] =
            PrayerAlarmSetting.fromJson(entry.value as Map<String, dynamic>);
      }
    }
  }
}
