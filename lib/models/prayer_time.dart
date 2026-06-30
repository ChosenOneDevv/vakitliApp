class PrayerTime {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String hijriDay;

  /// Gece yarısı vakti (Aladhan `Midnight`). Eski cache'te yoksa boş.
  final String midnight;

  /// Gecenin son üçte biri — teheccüd (Aladhan `Lastthird`). Yoksa boş.
  final String lastThird;

  PrayerTime({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriDay,
    this.midnight = '',
    this.lastThird = '',
  });

  factory PrayerTime.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final dateInfo = json['date'] as Map<String, dynamic>;
    final hijri = dateInfo['hijri'] as Map<String, dynamic>;
    final gregorian = dateInfo['gregorian'] as Map<String, dynamic>;

    String cleanTime(String time) {
      return time.split(' ').first;
    }

    return PrayerTime(
      fajr: cleanTime(timings['Fajr'] ?? ''),
      sunrise: cleanTime(timings['Sunrise'] ?? ''),
      dhuhr: cleanTime(timings['Dhuhr'] ?? ''),
      asr: cleanTime(timings['Asr'] ?? ''),
      maghrib: cleanTime(timings['Maghrib'] ?? ''),
      isha: cleanTime(timings['Isha'] ?? ''),
      date: gregorian['date'] ?? '',
      hijriDate: hijri['date'] ?? '',
      hijriMonth: hijri['month']?['en'] ?? '',
      hijriYear: hijri['year'] ?? '',
      hijriDay: hijri['day'] ?? '',
      midnight: cleanTime(timings['Midnight'] ?? ''),
      lastThird: cleanTime(timings['Lastthird'] ?? ''),
    );
  }

  /// Cache için düz JSON (Aladhan ham yapısı değil, ayrıştırılmış alanlar).
  Map<String, dynamic> toCacheJson() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'date': date,
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'hijriDay': hijriDay,
        'midnight': midnight,
        'lastThird': lastThird,
      };

  factory PrayerTime.fromCacheJson(Map<String, dynamic> json) {
    return PrayerTime(
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      date: json['date'] ?? '',
      hijriDate: json['hijriDate'] ?? '',
      hijriMonth: json['hijriMonth'] ?? '',
      hijriYear: json['hijriYear'] ?? '',
      hijriDay: json['hijriDay'] ?? '',
      midnight: json['midnight'] ?? '',
      lastThird: json['lastThird'] ?? '',
    );
  }

  static const Map<String, String> hijriMonthsTr = {
    'Muharram': 'Muharrem',
    'Safar': 'Safer',
    'Rabi al-Awwal': 'Rebîülevvel',
    'Rabi al-Thani': 'Rebîülâhir',
    'Jumada al-Ula': 'Cemâziyelevvel',
    'Jumada al-Thani': 'Cemâziyelâhir',
    'Rajab': 'Recep',
    'Sha\'ban': 'Şaban',
    'Ramadan': 'Ramazan',
    'Shawwal': 'Şevval',
    'Dhul Qi\'dah': 'Zilkade',
    'Dhul Hijjah': 'Zilhicce',
  };

  String get hijriMonthTr => hijriMonthsTr[hijriMonth] ?? hijriMonth;

  String get hijriFormatted => '$hijriDay $hijriMonthTr $hijriYear';

  List<PrayerEntry> get entries => [
        PrayerEntry(name: 'İmsak', time: fajr, icon: 'fajr'),
        PrayerEntry(name: 'Güneş', time: sunrise, icon: 'sunrise'),
        PrayerEntry(name: 'Öğle', time: dhuhr, icon: 'dhuhr'),
        PrayerEntry(name: 'İkindi', time: asr, icon: 'asr'),
        PrayerEntry(name: 'Akşam', time: maghrib, icon: 'maghrib'),
        PrayerEntry(name: 'Yatsı', time: isha, icon: 'isha'),
      ];
}

class PrayerEntry {
  final String name;
  final String time;
  final String icon;

  PrayerEntry({
    required this.name,
    required this.time,
    required this.icon,
  });

  DateTime get timeAsDateTime => timeOn(DateTime.now());

  /// Vaktin belirtilen güne ait DateTime değeri (yarının vakti vb. için).
  DateTime timeOn(DateTime day) {
    final parts = time.split(':');
    if (parts.length != 2) return day;
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }
}
