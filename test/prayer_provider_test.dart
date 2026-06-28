import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/services/api_service.dart';
import 'package:vakitli/services/prayer_cache_service.dart';

class FakeApiService extends ApiService {
  PrayerTime? daily;
  FakeApiService({this.daily});

  @override
  Future<PrayerTime?> getDailyPrayerTimes({
    required double latitude,
    required double longitude,
    int method = ApiService.defaultMethod,
    int hijriAdjustment = 0,
    DateTime? date,
  }) async =>
      daily;

  @override
  Future<List<PrayerTime>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    int method = ApiService.defaultMethod,
    int hijriAdjustment = 0,
    int? month,
    int? year,
  }) async =>
      [];
}

PrayerTime sample() => PrayerTime(
      fajr: '03:30',
      sunrise: '05:30',
      dhuhr: '13:10',
      asr: '17:05',
      maghrib: '20:40',
      isha: '22:30',
      date: '28-06-2026',
      hijriDate: '',
      hijriMonth: 'Ramadan',
      hijriYear: '1447',
      hijriDay: '1',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('başarılı fetch: vakitler set, offline değil, sonraki vakit var',
      () async {
    final provider = PrayerProvider(apiService: FakeApiService(daily: sample()));
    addTearDown(provider.dispose);

    await provider.fetchTodayPrayerTimes();

    expect(provider.todayPrayer, isNotNull);
    expect(provider.tomorrowPrayer, isNotNull);
    expect(provider.isOffline, false);
    expect(provider.error, isNull);
    expect(provider.nextPrayer, isNotNull);
  });

  test('ağ null + cache yok: hata set', () async {
    final provider = PrayerProvider(apiService: FakeApiService(daily: null));
    addTearDown(provider.dispose);

    await provider.fetchTodayPrayerTimes();

    expect(provider.todayPrayer, isNull);
    expect(provider.error, isNotNull);
  });

  test('ağ null + cache var: cache gösterilir, offline true', () async {
    // Önce bugünü cache'le.
    final cache = PrayerCacheService();
    await cache.put(
      PrayerProvider().latitude,
      PrayerProvider().longitude,
      DateTime.now(),
      sample(),
    );

    final provider = PrayerProvider(
      apiService: FakeApiService(daily: null),
      cache: cache,
    );
    addTearDown(provider.dispose);

    await provider.fetchTodayPrayerTimes();

    expect(provider.todayPrayer, isNotNull);
    expect(provider.isOffline, true);
    expect(provider.error, isNull);
  });
}
