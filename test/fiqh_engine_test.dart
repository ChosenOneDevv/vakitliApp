import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/flow_entry.dart';
import 'package:vakitli/models/madhhab.dart';
import 'package:vakitli/services/fiqh_engine.dart';

/// [pattern] sırasına göre 1 Ocak 2026'dan başlayan aralıksız günlük kayıt.
List<FlowEntry> entries(List<FlowType> pattern) {
  final start = DateTime(2026, 1, 1);
  return List.generate(
    pattern.length,
    (i) => FlowEntry(date: start.add(Duration(days: i)), type: pattern[i]),
  );
}

List<FlowType> bleed(int n) => List.filled(n, FlowType.bleeding);
List<FlowType> clean(int n) => List.filled(n, FlowType.clean);

List<FiqhStatus> statuses(List<FiqhDay> days) =>
    days.map((d) => d.status).toList();

void main() {
  final hanefi = FiqhEngine.forMadhhab(Madhhab.hanefi);

  group('Hanefi — min/max hayız', () {
    test('5 gün kanama → tamamı hayız (3 ≤ 5 ≤ 10)', () {
      final r = hanefi.classify(entries(bleed(5)));
      expect(statuses(r), List.filled(5, FiqhStatus.hayd));
    });

    test('2 gün kanama → istihaze (min 3 altı)', () {
      final r = hanefi.classify(entries(bleed(2)));
      expect(statuses(r), List.filled(2, FiqhStatus.istihaze));
    });

    test('3 gün kanama → hayız (min sınır)', () {
      final r = hanefi.classify(entries(bleed(3)));
      expect(statuses(r), List.filled(3, FiqhStatus.hayd));
    });

    test('12 gün kanama → ilk 10 hayız, son 2 istihaze (max 10)', () {
      final r = hanefi.classify(entries(bleed(12)));
      expect(statuses(r),
          [...List.filled(10, FiqhStatus.hayd), ...List.filled(2, FiqhStatus.istihaze)]);
    });
  });

  group('Hanefi — âdet (mutâde)', () {
    test('âdet 6, 9 gün kanama → ilk 6 hayız, kalan istihaze', () {
      final r = hanefi.classify(entries(bleed(9)), habitualHaydDays: 6);
      expect(statuses(r),
          [...List.filled(6, FiqhStatus.hayd), ...List.filled(3, FiqhStatus.istihaze)]);
    });
  });

  group('Hanefi — tuhr', () {
    test('5 kanama + 15 temiz + 5 kanama → iki ayrı hayız (tuhr sahih)', () {
      final r = hanefi.classify(entries([...bleed(5), ...clean(15), ...bleed(5)]));
      expect(statuses(r), [
        ...List.filled(5, FiqhStatus.hayd),
        ...List.filled(15, FiqhStatus.temiz),
        ...List.filled(5, FiqhStatus.hayd),
      ]);
    });

    test('kısa temizlik (tuhr fâsid) max pencere içinde kanama hükmünde', () {
      // 5 kanama + 3 temiz + 4 kanama = 12 günlük tek episode
      final r = hanefi.classify(entries([...bleed(5), ...clean(3), ...bleed(4)]));
      // İlk 10 gün hayız (ortadaki temizler dahil), son 2 istihaze
      expect(statuses(r),
          [...List.filled(10, FiqhStatus.hayd), ...List.filled(2, FiqhStatus.istihaze)]);
    });
  });

  group('Nifas', () {
    test('Hanefi 45 gün → ilk 40 nifas, son 5 istihaze (max 40)', () {
      final r = hanefi.classify(entries(bleed(45)), firstEpisodeIsNifas: true);
      expect(statuses(r),
          [...List.filled(40, FiqhStatus.nifas), ...List.filled(5, FiqhStatus.istihaze)]);
    });
  });

  group('Şafii — max 15', () {
    final safii = FiqhEngine.forMadhhab(Madhhab.safii);
    test('15 gün kanama → tamamı hayız', () {
      final r = safii.classify(entries(bleed(15)));
      expect(statuses(r), List.filled(15, FiqhStatus.hayd));
    });
    test('16 gün → 15 hayız + 1 istihaze', () {
      final r = safii.classify(entries(bleed(16)));
      expect(statuses(r),
          [...List.filled(15, FiqhStatus.hayd), FiqhStatus.istihaze]);
    });
    test('1 gün kanama → hayız (min 1)', () {
      final r = safii.classify(entries(bleed(1)));
      expect(statuses(r), [FiqhStatus.hayd]);
    });
  });

  group('Hanbeli — min tuhr 13', () {
    final hanbeli = FiqhEngine.forMadhhab(Madhhab.hanbeli);
    test('5 kanama + 13 temiz + 5 kanama → iki ayrı hayız', () {
      final r = hanbeli.classify(entries([...bleed(5), ...clean(13), ...bleed(5)]));
      expect(statuses(r), [
        ...List.filled(5, FiqhStatus.hayd),
        ...List.filled(13, FiqhStatus.temiz),
        ...List.filled(5, FiqhStatus.hayd),
      ]);
    });
  });

  group('currentStatus & kenar durumlar', () {
    test('boş liste → null', () {
      expect(hanefi.currentStatus([]), isNull);
    });
    test('son gün hayız episode içinde → hayd', () {
      expect(hanefi.currentStatus(entries(bleed(4))), FiqhStatus.hayd);
    });
    test('lekelenme kanama hükmünde', () {
      final r = hanefi.classify(entries(List.filled(4, FlowType.spotting)));
      expect(statuses(r), List.filled(4, FiqhStatus.hayd));
    });
    test('sırasız giriş içeride sıralanır', () {
      final unsorted = entries(bleed(3)).reversed.toList();
      final r = hanefi.classify(unsorted);
      expect(r.first.date.isBefore(r.last.date), isTrue);
    });
  });
}
