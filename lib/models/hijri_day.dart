import 'package:vakitli/models/prayer_time.dart';

class HijriDay {
  final DateTime gregorian;
  final String hijriDay;
  final String hijriMonthTr;
  final String hijriYear;
  final List<String> holidays;

  HijriDay({
    required this.gregorian,
    required this.hijriDay,
    required this.hijriMonthTr,
    required this.hijriYear,
    required this.holidays,
  });

  bool get hasHoliday => holidays.isNotEmpty;

  bool get isToday {
    final now = DateTime.now();
    return gregorian.year == now.year &&
        gregorian.month == now.month &&
        gregorian.day == now.day;
  }

  /// Aladhan İngilizce tatil adlarını Türkçeye çevirir.
  static const Map<String, String> _holidayTr = {
    'ramadan': 'Ramazan',
    'eid-ul-fitr': 'Ramazan Bayramı',
    'eid al-fitr': 'Ramazan Bayramı',
    'eid-ul-adha': 'Kurban Bayramı',
    'eid al-adha': 'Kurban Bayramı',
    'arafa': 'Arefe',
    'arafah': 'Arefe',
    'lailat-ul-qadr': 'Kadir Gecesi',
    'laylat al-qadr': 'Kadir Gecesi',
    'hijri new year': 'Hicri Yılbaşı',
    'islamic new year': 'Hicri Yılbaşı',
    'ashura': 'Aşure Günü',
    'mawlid': 'Mevlid Kandili',
    'mawlid al-nabi': 'Mevlid Kandili',
    'lailat-ul-miraj': 'Miraç Kandili',
    'isra and mi\'raj': 'Miraç Kandili',
    'lailat-ul-bara\'at': 'Berat Kandili',
    'mid-sha\'ban': 'Berat Kandili',
    'jumu\'atul-wida': 'Veda Cuması',
  };

  static String _translateHoliday(String en) {
    final lower = en.toLowerCase();
    for (final entry in _holidayTr.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return en; // bilinmeyen → orijinal
  }

  factory HijriDay.fromAladhanJson(Map<String, dynamic> json) {
    final greg = json['gregorian'] as Map<String, dynamic>;
    final hijri = json['hijri'] as Map<String, dynamic>;

    // gregorian.date: "dd-MM-yyyy"
    final parts = (greg['date'] as String).split('-');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final monthEn = hijri['month']?['en'] as String? ?? '';
    final monthTr = PrayerTime.hijriMonthsTr[monthEn] ?? monthEn;

    final rawHolidays = (hijri['holidays'] as List?)?.cast<String>() ?? [];
    final holidays = rawHolidays.map(_translateHoliday).toList();

    return HijriDay(
      gregorian: date,
      hijriDay: hijri['day'] as String? ?? '',
      hijriMonthTr: monthTr,
      hijriYear: hijri['year'] as String? ?? '',
      holidays: holidays,
    );
  }
}
