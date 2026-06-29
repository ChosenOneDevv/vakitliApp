import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vakitli/config/constants.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/models/hijri_day.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  // Diyanet İşleri metodu varsayılan: method=13
  static const int defaultMethod = 13;

  /// Asr mezhebi + yüksek enlem parametre eki.
  static String _fiqhSuffix(int school, int latitudeAdjustment) {
    var s = '&school=$school';
    if (latitudeAdjustment > 0) {
      s += '&latitudeAdjustmentMethod=$latitudeAdjustment';
    }
    return s;
  }

  Future<PrayerTime?> getDailyPrayerTimes({
    required double latitude,
    required double longitude,
    int method = defaultMethod,
    int hijriAdjustment = 0,
    int school = 0,
    int latitudeAdjustment = 0,
    DateTime? date,
  }) async {
    final now = date ?? DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final url = Uri.parse(
      '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=$method&adjustment=$hijriAdjustment${_fiqhSuffix(school, latitudeAdjustment)}',
    );

    try {
      final response =
          await http.get(url).timeout(AppConstants.httpTimeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['code'] == 200 && json['data'] != null) {
          return PrayerTime.fromAladhanJson(json['data']);
        }
      }
      debugPrint('ApiService.getDailyPrayerTimes: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ApiService.getDailyPrayerTimes hata: $e');
      return null;
    }
  }

  Future<List<PrayerTime>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    int method = defaultMethod,
    int hijriAdjustment = 0,
    int school = 0,
    int latitudeAdjustment = 0,
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;

    final url = Uri.parse(
      '$_baseUrl/calendar/$y/$m?latitude=$latitude&longitude=$longitude&method=$method&adjustment=$hijriAdjustment${_fiqhSuffix(school, latitudeAdjustment)}',
    );

    try {
      final response =
          await http.get(url).timeout(AppConstants.httpTimeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['code'] == 200 && json['data'] != null) {
          final dataList = json['data'] as List;
          return dataList
              .map((item) =>
                  PrayerTime.fromAladhanJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('ApiService.getMonthlyPrayerTimes hata: $e');
      return [];
    }
  }

  /// Bir Miladi ayın Hicri karşılıkları + dini günleri (Aladhan gToHCalendar).
  Future<List<HijriDay>> getHijriCalendar(int month, int year) async {
    final url = Uri.parse('$_baseUrl/gToHCalendar/$month/$year');
    try {
      final response =
          await http.get(url).timeout(AppConstants.httpTimeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['code'] == 200 && json['data'] != null) {
          final dataList = json['data'] as List;
          return dataList
              .map((item) =>
                  HijriDay.fromAladhanJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('ApiService.getHijriCalendar hata: $e');
      return [];
    }
  }
}
