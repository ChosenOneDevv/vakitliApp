import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_log.dart';
import 'package:vakitli/providers/tracker_provider.dart';
import 'package:vakitli/services/tracker_service.dart';

void main() {
  group('PrayerLog', () {
    test('empty has all false', () {
      final log = PrayerLog.empty('2026-06-28');
      expect(log.completedCount, 0);
      expect(log.isComplete, false);
    });

    test('completedCount and isComplete', () {
      final log = PrayerLog(
        date: '2026-06-28',
        status: {
          'fajr': true,
          'dhuhr': true,
          'asr': true,
          'maghrib': true,
          'isha': true,
        },
      );
      expect(log.completedCount, 5);
      expect(log.isComplete, true);
    });

    test('copyWithToggle flips a single key, leaves original untouched', () {
      final log = PrayerLog.empty('2026-06-28');
      final toggled = log.copyWithToggle('fajr');
      expect(toggled.isDone('fajr'), true);
      expect(log.isDone('fajr'), false); // immutable
      expect(toggled.completedCount, 1);
    });

    test('fromJson/toJson roundtrip', () {
      final log = PrayerLog.empty('2026-06-28').copyWithToggle('asr');
      final restored = PrayerLog.fromJson('2026-06-28', log.toJson());
      expect(restored.isDone('asr'), true);
      expect(restored.completedCount, 1);
    });
  });

  group('TrackerProvider stats', () {
    Map<String, dynamic> fullDay() =>
        {for (final k in PrayerLog.prayerKeys) k: true};

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<TrackerProvider> providerWith(Map<String, dynamic> logs) async {
      SharedPreferences.setMockInitialValues({
        'prayer_logs': jsonEncode(logs),
      });
      final provider = TrackerProvider();
      await provider.initialize();
      return provider;
    }

    test('streak counts consecutive full days ending today', () async {
      final now = DateTime.now();
      final logs = <String, dynamic>{};
      for (var i = 0; i < 3; i++) {
        final key = TrackerService.dateKey(now.subtract(Duration(days: i)));
        logs[key] = fullDay();
      }
      final provider = await providerWith(logs);
      expect(provider.streak, 3);
    });

    test('streak is 0 when neither today nor yesterday complete', () async {
      final now = DateTime.now();
      final key =
          TrackerService.dateKey(now.subtract(const Duration(days: 3)));
      final provider = await providerWith({key: fullDay()});
      expect(provider.streak, 0);
    });

    test('weeklySummary has 7 days ending today', () async {
      final provider = await providerWith({});
      final week = provider.weeklySummary;
      expect(week.length, 7);
      expect(
        TrackerService.dateKey(week.last.date),
        TrackerService.dateKey(DateTime.now()),
      );
    });

    test('totalCompleted sums all logged prayers', () async {
      final now = DateTime.now();
      final logs = {
        TrackerService.dateKey(now): {'fajr': true, 'dhuhr': true},
        TrackerService.dateKey(now.subtract(const Duration(days: 1))): {
          'asr': true,
        },
      };
      final provider = await providerWith(logs);
      expect(provider.totalCompleted, 3);
    });
  });
}
