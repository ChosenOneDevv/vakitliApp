import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/prayer_cache_service.dart';

PrayerTime sample(String date) => PrayerTime(
      fajr: '03:30',
      sunrise: '05:30',
      dhuhr: '13:10',
      asr: '17:05',
      maghrib: '20:40',
      isha: '22:30',
      date: date,
      hijriDate: '',
      hijriMonth: 'Ramadan',
      hijriYear: '1447',
      hijriDay: '1',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrayerTime serialization', () {
    test('toCacheJson/fromCacheJson roundtrip', () {
      final p = sample('15-06-2026');
      final restored = PrayerTime.fromCacheJson(p.toCacheJson());
      expect(restored.fajr, '03:30');
      expect(restored.isha, '22:30');
      expect(restored.hijriMonthTr, 'Ramazan');
    });
  });

  group('PrayerEntry.timeOn', () {
    test('binds time to given day', () {
      final entry = sample('x').entries.firstWhere((e) => e.icon == 'maghrib');
      final dt = entry.timeOn(DateTime(2026, 1, 2));
      expect(dt, DateTime(2026, 1, 2, 20, 40));
    });
  });

  group('PrayerCacheService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('put then get returns same times', () async {
      final cache = PrayerCacheService();
      final date = DateTime(2026, 6, 15);
      await cache.put(41.01, 28.98, date, sample('15-06-2026'));

      final got = await cache.get(41.01, 28.98, date);
      expect(got, isNotNull);
      expect(got!.dhuhr, '13:10');
    });

    test('get miss returns null', () async {
      final cache = PrayerCacheService();
      final got = await cache.get(0, 0, DateTime(2026, 6, 15));
      expect(got, isNull);
    });

    test('putMany caches by each entry date', () async {
      final cache = PrayerCacheService();
      await cache.putMany(41.01, 28.98, [
        sample('15-06-2026'),
        sample('16-06-2026'),
      ]);
      final d16 = await cache.get(41.01, 28.98, DateTime(2026, 6, 16));
      expect(d16, isNotNull);
      expect(d16!.fajr, '03:30');
    });

    test('coordinate rounding: same 2-decimal key hits', () async {
      final cache = PrayerCacheService();
      final date = DateTime(2026, 6, 15);
      await cache.put(41.012, 28.984, date, sample('15-06-2026'));
      // 41.011 -> "41.01" aynı anahtar
      final got = await cache.get(41.011, 28.983, date);
      expect(got, isNotNull);
    });
  });
}
