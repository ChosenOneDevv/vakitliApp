import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/alarm_settings.dart';

void main() {
  group('PrayerAlarmSetting', () {
    test('preset mode uses mode.minutesBefore', () {
      final s = PrayerAlarmSetting(
          prayerKey: 'fajr', prayerName: 'İmsak', mode: AlarmMode.before15);
      expect(s.effectiveMinutes, 15);
      expect(s.displayLabel, '15 dk önce');
    });

    test('onTime is 0 minutes', () {
      final s = PrayerAlarmSetting(
          prayerKey: 'dhuhr', prayerName: 'Öğle', mode: AlarmMode.onTime);
      expect(s.effectiveMinutes, 0);
    });

    test('custom mode uses customMinutes', () {
      final s = PrayerAlarmSetting(
        prayerKey: 'asr',
        prayerName: 'İkindi',
        mode: AlarmMode.custom,
        customMinutes: 42,
      );
      expect(s.effectiveMinutes, 42);
      expect(s.displayLabel, '42 dk önce');
    });

    test('toJson/fromJson preserves custom minutes', () {
      final s = PrayerAlarmSetting(
        prayerKey: 'isha',
        prayerName: 'Yatsı',
        enabled: true,
        mode: AlarmMode.custom,
        customMinutes: 25,
      );
      final restored = PrayerAlarmSetting.fromJson(s.toJson());
      expect(restored.mode, AlarmMode.custom);
      expect(restored.customMinutes, 25);
      expect(restored.enabled, true);
    });

    test('old json without customMinutes defaults to 10', () {
      final restored = PrayerAlarmSetting.fromJson({
        'prayerKey': 'fajr',
        'prayerName': 'İmsak',
        'enabled': false,
        'mode': AlarmMode.onTime.index,
      });
      expect(restored.customMinutes, 10);
    });
  });
}
