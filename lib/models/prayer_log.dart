/// Bir günün 5 farz namaz kılınma + cemaat durumu.
class PrayerLog {
  /// Gün anahtarı: 'yyyy-MM-dd'
  final String date;

  /// prayerKey -> kılındı mı
  final Map<String, bool> status;

  /// prayerKey -> cemaatle mi kılındı
  final Map<String, bool> jamaah;

  PrayerLog({required this.date, required this.status, Map<String, bool>? jamaah})
      : jamaah = jamaah ?? {for (final key in prayerKeys) key: false};

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
  bool isJamaah(String key) => jamaah[key] ?? false;

  /// O gün kılınan farz namaz sayısı (0-5).
  int get completedCount => prayerKeys.where(isDone).length;

  /// O gün cemaatle kılınan farz sayısı.
  int get jamaahCount => prayerKeys.where(isJamaah).length;

  /// Beş vakit tamamlandı mı.
  bool get isComplete => completedCount == prayerKeys.length;

  PrayerLog copyWithToggle(String key) {
    final next = Map<String, bool>.from(status);
    final wasDone = next[key] ?? false;
    next[key] = !wasDone;
    // Vakit "kılınmadı"ya dönerse cemaat işareti de düşer.
    final nextJamaah = Map<String, bool>.from(jamaah);
    if (wasDone) nextJamaah[key] = false;
    return PrayerLog(date: date, status: next, jamaah: nextJamaah);
  }

  /// Cemaat işaretini değiştirir; sadece vakit kılınmışsa anlamlı.
  PrayerLog copyWithJamaahToggle(String key) {
    if (!isDone(key)) return this;
    final next = Map<String, bool>.from(jamaah);
    next[key] = !(next[key] ?? false);
    return PrayerLog(date: date, status: status, jamaah: next);
  }

  Map<String, dynamic> toJson() => {'status': status, 'jamaah': jamaah};

  factory PrayerLog.fromJson(String date, Map<String, dynamic> json) {
    // Geriye uyumluluk: eski format düz {fajr:true,...}; yeni {status:{}, jamaah:{}}.
    final isNew = json.containsKey('status');
    final statusSrc =
        isNew ? (json['status'] as Map<String, dynamic>) : json;
    final jamaahSrc = isNew ? (json['jamaah'] as Map<String, dynamic>?) : null;
    return PrayerLog(
      date: date,
      status: {
        for (final key in prayerKeys) key: (statusSrc[key] as bool?) ?? false,
      },
      jamaah: {
        for (final key in prayerKeys)
          key: (jamaahSrc?[key] as bool?) ?? false,
      },
    );
  }
}
