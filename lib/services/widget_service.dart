import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Ana ekran widget'ına veri yazar ve günceller (Android).
class WidgetService {
  static const String _androidName = 'VakitliWidgetProvider';

  static Future<void> update({
    required String prayerName,
    required String time,
    required String remaining,
    required String city,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_next_name', prayerName);
      await HomeWidget.saveWidgetData<String>('widget_next_time', time);
      await HomeWidget.saveWidgetData<String>('widget_remaining', remaining);
      await HomeWidget.saveWidgetData<String>('widget_city', city);
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (e) {
      debugPrint('WidgetService.update hata: $e');
    }
  }
}
