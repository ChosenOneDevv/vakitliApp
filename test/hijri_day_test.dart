import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/hijri_day.dart';
import 'package:vakitli/models/mosque.dart';

void main() {
  group('HijriDay.fromAladhanJson', () {
    Map<String, dynamic> day(List<String> holidays) => {
          'gregorian': {'date': '28-06-2026'},
          'hijri': {
            'day': '13',
            'month': {'en': 'Dhul Hijjah'},
            'year': '1447',
            'holidays': holidays,
          },
        };

    test('parses gregorian date + hijri month TR', () {
      final d = HijriDay.fromAladhanJson(day([]));
      expect(d.gregorian, DateTime(2026, 6, 28));
      expect(d.hijriMonthTr, 'Zilhicce');
      expect(d.hasHoliday, false);
    });

    test('translates known holidays to Turkish', () {
      final d = HijriDay.fromAladhanJson(day(['Eid-ul-Adha']));
      expect(d.holidays, contains('Kurban Bayramı'));
      expect(d.hasHoliday, true);
    });

    test('unknown holiday is silently dropped', () {
      final d = HijriDay.fromAladhanJson(day(['Some Local Day']));
      expect(d.holidays, isEmpty);
      expect(d.hasHoliday, false);
    });
  });

  group('Mosque.distanceLabel', () {
    test('meters under 1km', () {
      final m = Mosque(name: 'x', latitude: 0, longitude: 0, distanceMeters: 450);
      expect(m.distanceLabel, '450 m');
    });

    test('km over 1000m', () {
      final m =
          Mosque(name: 'x', latitude: 0, longitude: 0, distanceMeters: 2300);
      expect(m.distanceLabel, '2.3 km');
    });
  });
}
