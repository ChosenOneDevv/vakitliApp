import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vakitli/models/alarm_settings.dart';
import 'package:vakitli/models/prayer_time.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // Android 12+ tam zamanlı alarm izni (vaktinde bildirim için şart).
      await android.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Android 12+ tam zamanlı alarm izni var mı.
  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required AlarmMode mode,
  }) async {
    final actualTime =
        scheduledTime.subtract(Duration(minutes: mode.minutesBefore));

    if (actualTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(actualTime, tz.local);

    String body;
    if (mode == AlarmMode.onTime) {
      body = '$prayerName vakti girdi.';
    } else {
      body = '$prayerName vaktine ${mode.minutesBefore} dakika kaldı.';
    }

    final androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Namaz Vakitleri',
      channelDescription: 'Namaz vakti bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Vakitli - $prayerName',
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// Bugün (kalan vakitler) + yarın (tüm vakitler) için bildirim kurar.
  /// Gün dönünce uygulama açılışında yeniden çağrılarak güncellenir.
  Future<void> scheduleAllPrayerNotifications({
    required PrayerTime prayerTime,
    PrayerTime? tomorrowPrayer,
    required AlarmSettings alarmSettings,
  }) async {
    await cancelAllNotifications();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    await _scheduleDay(prayerTime, today, alarmSettings, idBase: 0);
    if (tomorrowPrayer != null) {
      await _scheduleDay(tomorrowPrayer, tomorrow, alarmSettings, idBase: 100);
    }
  }

  Future<void> _scheduleDay(
    PrayerTime prayerTime,
    DateTime day,
    AlarmSettings alarmSettings, {
    required int idBase,
  }) async {
    final entries = prayerTime.entries;
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final setting = alarmSettings.getSetting(entry.icon);

      if (!setting.enabled || setting.mode == AlarmMode.off) continue;

      await schedulePrayerNotification(
        id: idBase + i + 1,
        prayerName: entry.name,
        scheduledTime: entry.timeOn(day),
        mode: setting.mode,
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
