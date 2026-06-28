import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/prayer_time.dart';

void main() {
  group('PrayerTime.fromAladhanJson', () {
    final json = {
      'timings': {
        'Fajr': '03:30 (+03)',
        'Sunrise': '05:30 (+03)',
        'Dhuhr': '13:10 (+03)',
        'Asr': '17:05 (+03)',
        'Maghrib': '20:40 (+03)',
        'Isha': '22:30 (+03)',
      },
      'date': {
        'gregorian': {'date': '28-06-2026'},
        'hijri': {
          'date': '13-12-1447',
          'month': {'en': 'Dhul Hijjah'},
          'year': '1447',
          'day': '13',
        },
      },
    };

    test('strips timezone suffix from timings', () {
      final p = PrayerTime.fromAladhanJson(json);
      expect(p.fajr, '03:30');
      expect(p.isha, '22:30');
    });

    test('maps hijri month to Turkish', () {
      final p = PrayerTime.fromAladhanJson(json);
      expect(p.hijriMonthTr, 'Zilhicce');
      expect(p.hijriFormatted, '13 Zilhicce 1447');
    });

    test('entries contain 6 prayers including sunrise', () {
      final p = PrayerTime.fromAladhanJson(json);
      expect(p.entries.length, 6);
      expect(p.entries.map((e) => e.icon), contains('sunrise'));
    });
  });
}
