import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/qibla_service.dart';

/// Ana ekran widget'larına veri yazar ve günceller (Android).
class WidgetService {
  // Android widget provider sınıf adları.
  static const String _nextName = 'VakitliWidgetProvider';
  static const String _timesName = 'VakitliTimesWidgetProvider';
  static const String _countdownName = 'VakitliCountdownWidgetProvider';
  static const String _hijriQiblaName = 'VakitliHijriQiblaWidgetProvider';
  static const String _hadithName = 'VakitliHadithWidgetProvider';

  /// Namaz vakti kaynaklı tüm widget'ları (sonraki vakit, günün vakitleri,
  /// geri sayım, hicri+kıble) tek seferde günceller.
  static Future<void> updatePrayerData({
    required String prayerName,
    required String time,
    required String remaining,
    required String city,
    required double latitude,
    required double longitude,
    PrayerTime? today,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_next_name', prayerName);
      await HomeWidget.saveWidgetData<String>('widget_next_time', time);
      await HomeWidget.saveWidgetData<String>('widget_remaining', remaining);
      await HomeWidget.saveWidgetData<String>('widget_city', city);

      if (today != null) {
        final entries = today.entries;
        for (var i = 0; i < 6; i++) {
          final name = i < entries.length ? entries[i].name : '';
          final t = i < entries.length ? entries[i].time : '';
          await HomeWidget.saveWidgetData<String>('w_name_$i', name);
          await HomeWidget.saveWidgetData<String>('w_time_$i', t);
        }
        await HomeWidget.saveWidgetData<String>(
          'w_hijri',
          '${today.hijriDay} ${today.hijriMonthTr} ${today.hijriYear}',
        );
      }

      final qibla = QiblaService.calculateQiblaDirection(latitude, longitude);
      await HomeWidget.saveWidgetData<String>(
          'w_qibla', '${qibla.toStringAsFixed(0)}°');

      await HomeWidget.updateWidget(androidName: _nextName);
      await HomeWidget.updateWidget(androidName: _timesName);
      await HomeWidget.updateWidget(androidName: _countdownName);
      await HomeWidget.updateWidget(androidName: _hijriQiblaName);
    } catch (e) {
      debugPrint('WidgetService.updatePrayerData hata: $e');
    }
  }

  /// Günün hadisi widget'ını günceller.
  static Future<void> updateHadith({
    required String text,
    required String source,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('w_hadith_text', text);
      await HomeWidget.saveWidgetData<String>('w_hadith_source', source);
      await HomeWidget.updateWidget(androidName: _hadithName);
    } catch (e) {
      debugPrint('WidgetService.updateHadith hata: $e');
    }
  }
}
