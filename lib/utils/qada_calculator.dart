class QadaCalculation {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
  final int witr;

  const QadaCalculation({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.witr,
  });

  const QadaCalculation.zero()
      : fajr = 0,
        dhuhr = 0,
        asr = 0,
        maghrib = 0,
        isha = 0,
        witr = 0;

  int get total => fajr + dhuhr + asr + maghrib + isha + witr;
}

class QadaCalculator {
  /// Buluğ tarihinden namaza başlama tarihine kadar kılınmayan
  /// namazları hesaplar.
  ///
  /// [bulughDate] — buluğ tarihi (dahil).
  /// [prayerStartDate] — namaza düzenli başlanan tarih (dahil değil).
  /// [isViterWajib] — Hanefî mezhebinde true; vitir kazası oluşur.
  /// [monthlyHaydDays] — Kadın için aylık ortalama hayız günü (0=erkek).
  ///   Hayızlı günlerde farz + vitir borcu oluşmaz.
  static QadaCalculation calculate({
    required DateTime bulughDate,
    required DateTime prayerStartDate,
    required bool isViterWajib,
    int monthlyHaydDays = 0,
  }) {
    final start = DateTime(bulughDate.year, bulughDate.month, bulughDate.day);
    final end =
        DateTime(prayerStartDate.year, prayerStartDate.month, prayerStartDate.day);

    if (!end.isAfter(start)) return const QadaCalculation.zero();

    final totalDays = end.difference(start).inDays;

    int haydDays = 0;
    if (monthlyHaydDays > 0) {
      // Her ay içindeki tahmini hayız günü (ay = 30.44 gün ortalama).
      final months = totalDays / 30.44;
      haydDays = (months * monthlyHaydDays).round().clamp(0, totalDays);
    }

    final fardDays = totalDays - haydDays;

    return QadaCalculation(
      fajr: fardDays,
      dhuhr: fardDays,
      asr: fardDays,
      maghrib: fardDays,
      isha: fardDays,
      witr: isViterWajib ? fardDays : 0,
    );
  }
}
