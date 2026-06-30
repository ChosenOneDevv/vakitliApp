import 'package:vakitli/models/flow_entry.dart';
import 'package:vakitli/models/madhhab.dart';

/// Bir günün fıkhi hükmü.
enum FiqhStatus {
  /// Hayız — namaz/oruç muaf.
  hayd,

  /// İstihaze (özür kanı) — namaza devam, oruç tutulur.
  istihaze,

  /// Nifas (loğusalık) — namaz/oruç muaf.
  nifas,

  /// Temiz — ibadet normal.
  temiz,
}

/// Bir güne ait fıkhi tespit sonucu.
class FiqhDay {
  final DateTime date;
  final FiqhStatus status;

  const FiqhDay({required this.date, required this.status});

  @override
  bool operator ==(Object other) =>
      other is FiqhDay && other.date == date && other.status == status;

  @override
  int get hashCode => Object.hash(date, status);

  @override
  String toString() => 'FiqhDay($date, $status)';
}

/// Saf, stateless fıkhi tespit motoru (Faz 24c).
///
/// Günlük akıntı kayıtlarından hayız / istihaze / nifas / temiz hükmünü
/// mezhep sınırlarına göre belirler. Lekelenme (sufra/kudra) kanama
/// hükmündedir.
///
/// ⚠️ KISITLAR (yayın öncesi ilim ehline doğrulatılacak):
/// - Âdet (mutâde) + istizhar kuralları sadeleştirilmiştir.
/// - Tuhr fâsid (max pencere içinde kısa temizlik) kanama hükmünde
///   sayılır; ancak mezhepler arası ince farklar tam modellenmemiştir.
/// - Maliki'nin âdet+istizhar genişlemesi uygulanmamıştır.
class FiqhEngine {
  final MadhhabRules rules;

  const FiqhEngine(this.rules);

  factory FiqhEngine.forMadhhab(Madhhab madhhab) =>
      FiqhEngine(MadhhabRules.of(madhhab));

  /// Akıntı kayıtlarını fıkhi günlere çevirir.
  ///
  /// [entries] günlük ve mümkünse aralıksız (her takvim günü için bir kayıt)
  /// olmalıdır. Sıralı olması gerekmez; içeride tarihe göre sıralanır.
  ///
  /// [habitualHaydDays] verilirse (mutâde/alışkın kadın) hayız uzunluğu
  /// bu değere göre belirlenir; verilmezse (müptedie) episode uzunluğu
  /// max sınırına kadar hayız sayılır.
  ///
  /// [firstEpisodeIsNifas] true ise listedeki ilk kanama episode'u nifas
  /// (loğusalık) olarak değerlendirilir.
  List<FiqhDay> classify(
    List<FlowEntry> entries, {
    int? habitualHaydDays,
    bool firstEpisodeIsNifas = false,
  }) {
    if (entries.isEmpty) return const [];

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final result = <FiqhDay>[];
    var firstEpisodeHandled = false;
    var i = 0;

    while (i < sorted.length) {
      if (!sorted[i].type.isBloody) {
        result.add(FiqhDay(date: sorted[i].date, status: FiqhStatus.temiz));
        i++;
        continue;
      }

      // Episode başlangıcı: min tuhr kadar aralıksız temiz görülene dek sürer.
      final start = i;
      var lastBloody = i;
      var cleanRun = 0;
      var j = i;
      while (j < sorted.length) {
        if (sorted[j].type.isBloody) {
          lastBloody = j;
          cleanRun = 0;
        } else {
          cleanRun++;
          if (cleanRun >= rules.minTuhrDays) break;
        }
        j++;
      }

      final episodeLen = lastBloody - start + 1;
      final isNifas = firstEpisodeIsNifas && !firstEpisodeHandled;
      firstEpisodeHandled = true;

      _classifyEpisode(
        sorted: sorted,
        start: start,
        lastBloody: lastBloody,
        episodeLen: episodeLen,
        habitualHaydDays: habitualHaydDays,
        isNifas: isNifas,
        result: result,
      );

      // Episode ile bir sonraki episode arasındaki temiz günler.
      for (var k = lastBloody + 1; k < j; k++) {
        result.add(FiqhDay(date: sorted[k].date, status: FiqhStatus.temiz));
      }
      i = j;
    }

    return result;
  }

  void _classifyEpisode({
    required List<FlowEntry> sorted,
    required int start,
    required int lastBloody,
    required int episodeLen,
    required int? habitualHaydDays,
    required bool isNifas,
    required List<FiqhDay> result,
  }) {
    final int exemptLen;
    if (isNifas) {
      exemptLen =
          episodeLen < rules.maxNifasDays ? episodeLen : rules.maxNifasDays;
    } else if (episodeLen < rules.minHaydDays) {
      // Min süreden kısa kanama → tamamı istihaze.
      exemptLen = 0;
    } else if (habitualHaydDays != null) {
      exemptLen = habitualHaydDays.clamp(rules.minHaydDays, rules.maxHaydDays);
    } else {
      exemptLen =
          episodeLen < rules.maxHaydDays ? episodeLen : rules.maxHaydDays;
    }

    final exemptStatus = isNifas ? FiqhStatus.nifas : FiqhStatus.hayd;
    for (var k = start; k <= lastBloody; k++) {
      final offset = k - start;
      final status =
          offset < exemptLen ? exemptStatus : FiqhStatus.istihaze;
      result.add(FiqhDay(date: sorted[k].date, status: status));
    }
  }

  /// Verilen kayıtlara göre son günün (bugünkü) fıkhi durumu.
  FiqhStatus? currentStatus(
    List<FlowEntry> entries, {
    int? habitualHaydDays,
    bool firstEpisodeIsNifas = false,
  }) {
    final days = classify(
      entries,
      habitualHaydDays: habitualHaydDays,
      firstEpisodeIsNifas: firstEpisodeIsNifas,
    );
    return days.isEmpty ? null : days.last.status;
  }
}
