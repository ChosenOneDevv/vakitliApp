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
    // Ramazan
    'ramadan': 'Ramazan',
    // Ramazan Bayramı
    'eid-ul-fitr': 'Ramazan Bayramı',
    'eid al-fitr': 'Ramazan Bayramı',
    'eid ul-fitr': 'Ramazan Bayramı',
    'fitr': 'Ramazan Bayramı',
    // Kurban Bayramı
    'eid-ul-adha': 'Kurban Bayramı',
    'eid al-adha': 'Kurban Bayramı',
    'eid ul-adha': 'Kurban Bayramı',
    'adha': 'Kurban Bayramı',
    // Arefe
    'arafa': 'Arefe',
    'arafah': 'Arefe',
    'day of arafah': 'Arefe',
    // Kadir Gecesi
    'lailat-ul-qadr': 'Kadir Gecesi',
    'laylat al-qadr': 'Kadir Gecesi',
    'lailat al-qadr': 'Kadir Gecesi',
    'night of power': 'Kadir Gecesi',
    'night of decree': 'Kadir Gecesi',
    'qadr': 'Kadir Gecesi',
    // Hicri Yılbaşı
    'hijri new year': 'Hicri Yılbaşı',
    'islamic new year': 'Hicri Yılbaşı',
    'new hijri year': 'Hicri Yılbaşı',
    'muharram': 'Hicri Yılbaşı',
    // Aşure
    'ashura': 'Aşure Günü',
    'ashoura': 'Aşure Günü',
    'day of ashura': 'Aşure Günü',
    // Mevlid
    'mawlid': 'Mevlid Kandili',
    'mawlid al-nabi': 'Mevlid Kandili',
    'mawlid an-nabi': 'Mevlid Kandili',
    'milad un nabi': 'Mevlid Kandili',
    'prophet\'s birthday': 'Mevlid Kandili',
    // Miraç
    'lailat-ul-miraj': 'Miraç Kandili',
    'laylat al-miraj': 'Miraç Kandili',
    'isra and mi\'raj': 'Miraç Kandili',
    'isra wal miraj': 'Miraç Kandili',
    'al-isra\' wal-mi\'raj': 'Miraç Kandili',
    'miraj': 'Miraç Kandili',
    // Berat
    'lailat-ul-bara\'at': 'Berat Kandili',
    'laylat al-bara\'at': 'Berat Kandili',
    'mid-sha\'ban': 'Berat Kandili',
    'shab e barat': 'Berat Kandili',
    'bara\'at': 'Berat Kandili',
    'barat': 'Berat Kandili',
    // Regaip
    'lailat-ul-raghaib': 'Regaip Kandili',
    'raghaib': 'Regaip Kandili',
    'ragaib': 'Regaip Kandili',
    // Veda Cuması
    'jumu\'atul-wida': 'Veda Cuması',
    'juma al-wida': 'Veda Cuması',
    'last friday of ramadan': 'Veda Cuması',
  };

  static String? _translateHoliday(String en) {
    final lower = en.toLowerCase();
    for (final entry in _holidayTr.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null; // Tanınmayan string → gösterme
  }

  factory HijriDay.fromAladhanJson(Map<String, dynamic> json) {
    final greg = json['gregorian'] as Map<String, dynamic>;
    final hijri = json['hijri'] as Map<String, dynamic>;

    // gregorian.date: "dd-MM-yyyy"
    final parts = (greg['date'] as String? ?? '').split('-');
    final y = parts.length == 3 ? int.tryParse(parts[2]) : null;
    final mo = parts.length == 3 ? int.tryParse(parts[1]) : null;
    final d = parts.length == 3 ? int.tryParse(parts[0]) : null;
    final date = DateTime(y ?? 2000, mo ?? 1, d ?? 1);

    final monthEn = hijri['month']?['en'] as String? ?? '';
    final monthTr = PrayerTime.hijriMonthsTr[monthEn] ?? monthEn;

    final rawHolidays = (hijri['holidays'] as List?)?.cast<String>() ?? [];
    final holidays = rawHolidays
        .map(_translateHoliday)
        .whereType<String>()
        .toList();

    return HijriDay(
      gregorian: date,
      hijriDay: hijri['day'] as String? ?? '',
      hijriMonthTr: monthTr,
      hijriYear: hijri['year'] as String? ?? '',
      holidays: holidays,
    );
  }
}
