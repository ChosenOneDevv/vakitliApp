import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:vakitli/config/constants.dart';
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
    await _createAndroidChannels();
    _initialized = true;
  }

  /// Android kanallarını ses ayarıyla açıkça oluşturur.
  /// Kanal sesi ilk oluşturmada önbelleğe alındığından, ezan kanalı doğru
  /// sesle kurulmazsa ses hiç çalmaz. Eski/sessiz ezan kanalını silip yeniden
  /// oluşturuyoruz.
  Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Önbelleğe takılı eski ezan kanalını temizle.
    await android.deleteNotificationChannel(AppConstants.ezanChannelIdLegacy);

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.ezanChannelId,
        AppConstants.ezanChannelName,
        description: 'Namaz vakti ezan sesiyle bildirimi',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(AppConstants.ezanSoundFile),
        playSound: true,
        enableVibration: false,
      ),
    );

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.prayerChannelId,
        AppConstants.prayerChannelName,
        description: AppConstants.prayerChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
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
    required int minutesBefore,
    bool useEzan = false,
  }) async {
    final actualTime =
        scheduledTime.subtract(Duration(minutes: minutesBefore));

    if (actualTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(actualTime, tz.local);

    String body;
    if (minutesBefore == 0) {
      body = '$prayerName vakti girdi.';
    } else {
      body = '$prayerName vaktine $minutesBefore dakika kaldı.';
    }

    final androidDetails = useEzan
        ? AndroidNotificationDetails(
            AppConstants.ezanChannelId,
            AppConstants.ezanChannelName,
            channelDescription: 'Namaz vakti ezan sesiyle bildirimi',
            importance: Importance.high,
            priority: Priority.high,
            sound: const RawResourceAndroidNotificationSound(
                AppConstants.ezanSoundFile),
            playSound: true,
            enableVibration: false,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
            groupKey: AppConstants.prayerGroupKey,
          )
        : AndroidNotificationDetails(
            AppConstants.prayerChannelId,
            AppConstants.prayerChannelName,
            channelDescription: AppConstants.prayerChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
            groupKey: AppConstants.prayerGroupKey,
          );

    final iosDetails = useEzan
        ? const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: '${AppConstants.ezanSoundFile}.mp3',
          )
        : const DarwinNotificationDetails(
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

  /// Sistem bildirim çubuğunda kalıcı "sonraki vakit" göstergesi.
  ///
  /// Genişletilince o günün tüm namaz vakitlerini listeler; sonraki vakit
  /// `▸` ile işaretlenir. [nextPrayerName] o gün içinde yoksa (gün sonu)
  /// işaret atlanır.
  Future<void> showOngoingNotification({
    required String nextPrayerName,
    required String prayerTime,
    required String remaining,
    List<PrayerEntry> todayEntries = const [],
  }) async {
    final lines = todayEntries
        .map((e) => e.name == nextPrayerName
            ? '▸ ${e.name}   ${e.time}'
            : '${e.name}   ${e.time}')
        .toList();

    final androidDetails = AndroidNotificationDetails(
      AppConstants.ongoingChannelId,
      AppConstants.ongoingChannelName,
      channelDescription: 'Sonraki namaz vaktini sürekli gösterir',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      channelShowBadge: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: lines.isEmpty
          ? null
          : InboxStyleInformation(
              lines,
              contentTitle: 'Vakitli — $nextPrayerName',
              summaryText: '$prayerTime · $remaining kaldı',
            ),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      AppConstants.ongoingNotifId,
      'Vakitli — $nextPrayerName',
      '$prayerTime · $remaining kaldı',
      details,
    );
  }

  Future<void> cancelOngoingNotification() async {
    await _plugin.cancel(AppConstants.ongoingNotifId);
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
      await _scheduleDay(tomorrowPrayer, tomorrow, alarmSettings, idBase: 200);
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

      final beforeId = idBase + i * 2 + 1;
      final onTimeId = idBase + i * 2 + 2;

      await schedulePrayerNotification(
        id: beforeId,
        prayerName: entry.name,
        scheduledTime: entry.timeOn(day),
        minutesBefore: setting.effectiveMinutes,
        useEzan: setting.useEzan,
      );

      // Önce alarm + vakitte de bildir seçeneği
      if (setting.alsoOnTime && setting.effectiveMinutes > 0) {
        await schedulePrayerNotification(
          id: onTimeId,
          prayerName: entry.name,
          scheduledTime: entry.timeOn(day),
          minutesBefore: 0,
          useEzan: setting.useEzan,
        );
      }
    }

    // Teheccüd — vakit listesinde yok, `lastThird` (gecenin son üçte biri) ile kur.
    final tahajjud = alarmSettings.getSetting('tahajjud');
    if (tahajjud.enabled &&
        tahajjud.mode != AlarmMode.off &&
        prayerTime.lastThird.isNotEmpty) {
      final parts = prayerTime.lastThird.split(':');
      if (parts.length == 2) {
        final t = DateTime(
          day.year,
          day.month,
          day.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
        await schedulePrayerNotification(
          id: idBase + 199,
          prayerName: 'Teheccüd',
          scheduledTime: t,
          minutesBefore: tahajjud.effectiveMinutes,
          useEzan: tahajjud.useEzan,
        );
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
