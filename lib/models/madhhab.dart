/// Hayız/istihaze/nifas fıkhi hesabı için mezhep.
///
/// NOT: Bu mezhep, namaz vakti hesabındaki (silinen) Asr mezhebinden
/// bağımsızdır; yalnızca regl/muafiyet fıkhi motorunda kullanılır.
///
/// ⚠️ Maliki ve Hanbeli sınır değerleri ile istizhar/âdet kuralları
/// yayın öncesi bir ilim ehline doğrulatılmalıdır (Faz 24 notu).
enum Madhhab { hanefi, safii, maliki, hanbeli }

extension MadhhabTr on Madhhab {
  String get displayName {
    switch (this) {
      case Madhhab.hanefi:
        return 'Hanefi';
      case Madhhab.safii:
        return 'Şafii';
      case Madhhab.maliki:
        return 'Maliki';
      case Madhhab.hanbeli:
        return 'Hanbeli';
    }
  }
}

/// Bir mezhebin hayız/tuhr/nifas gün sınırları (fıkhi sabitler).
class MadhhabRules {
  /// En az hayız süresi (gün). Bundan kısa kanama → istihaze.
  final int minHaydDays;

  /// En çok hayız süresi (gün). Bunu aşan fazlalık → istihaze.
  final int maxHaydDays;

  /// İki hayız arası en az temizlik (tuhr) süresi (gün).
  final int minTuhrDays;

  /// En çok nifas (loğusalık) süresi (gün).
  final int maxNifasDays;

  const MadhhabRules({
    required this.minHaydDays,
    required this.maxHaydDays,
    required this.minTuhrDays,
    required this.maxNifasDays,
  });

  /// Mezhep → kural tablosu (Faz 24a sabitleri).
  static const Map<Madhhab, MadhhabRules> table = {
    Madhhab.hanefi: MadhhabRules(
      minHaydDays: 3,
      maxHaydDays: 10,
      minTuhrDays: 15,
      maxNifasDays: 40,
    ),
    Madhhab.safii: MadhhabRules(
      minHaydDays: 1,
      maxHaydDays: 15,
      minTuhrDays: 15,
      maxNifasDays: 60,
    ),
    // ⚠️ doğrulanacak
    Madhhab.maliki: MadhhabRules(
      minHaydDays: 1,
      maxHaydDays: 15,
      minTuhrDays: 15,
      maxNifasDays: 60,
    ),
    // ⚠️ doğrulanacak
    Madhhab.hanbeli: MadhhabRules(
      minHaydDays: 1,
      maxHaydDays: 15,
      minTuhrDays: 13,
      maxNifasDays: 40,
    ),
  };

  static MadhhabRules of(Madhhab madhhab) => table[madhhab]!;
}
