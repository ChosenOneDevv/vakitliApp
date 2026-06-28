/// Bir günün 5 farz namaz kılınma durumu.
class PrayerLog {
  /// Gün anahtarı: 'yyyy-MM-dd'
  final String date;

  /// prayerKey -> kılındı mı
  final Map<String, bool> status;

  PrayerLog({required this.date, required this.status});

  /// Takip edilen 5 farz namaz (Güneş/sunrise farz değil, dahil değil).
  static const List<String> prayerKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const Map<String, String> prayerNames = {
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
  };

  factory PrayerLog.empty(String date) {
    return PrayerLog(
      date: date,
      status: {for (final key in prayerKeys) key: false},
    );
  }

  bool isDone(String key) => status[key] ?? false;

  /// O gün kılınan farz namaz sayısı (0-5).
  int get completedCount => prayerKeys.where(isDone).length;

  /// Beş vakit tamamlandı mı.
  bool get isComplete => completedCount == prayerKeys.length;

  PrayerLog copyWithToggle(String key) {
    final next = Map<String, bool>.from(status);
    next[key] = !(next[key] ?? false);
    return PrayerLog(date: date, status: next);
  }

  Map<String, dynamic> toJson() => status;

  factory PrayerLog.fromJson(String date, Map<String, dynamic> json) {
    return PrayerLog(
      date: date,
      status: {
        for (final key in prayerKeys) key: (json[key] as bool?) ?? false,
      },
    );
  }
}
