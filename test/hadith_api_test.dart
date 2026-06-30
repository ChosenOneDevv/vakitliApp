import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/hadith.dart';
import 'package:vakitli/services/hadith_api_service.dart';

void main() {
  group('HadithCategory.fromJson', () {
    test('parses normal response', () {
      final cat = HadithCategory.fromJson({
        'id': '4',
        'title': 'İbadet',
        'hadeeths_count': '120',
      });
      expect(cat.id, '4');
      expect(cat.title, 'İbadet');
      expect(cat.hadithCount, 120);
    });

    test('handles int id', () {
      final cat = HadithCategory.fromJson({
        'id': 7,
        'title': 'Ahlak',
        'hadeeths_count': '55',
      });
      expect(cat.id, '7');
    });

    test('defaults to 0 count when missing', () {
      final cat = HadithCategory.fromJson({
        'id': '1',
        'title': 'Test',
        'hadeeths_count': null,
      });
      expect(cat.hadithCount, 0);
    });
  });

  group('Hadith.fromApiJson', () {
    test('maps HadeethEnc fields correctly', () {
      final hadith = Hadith.fromApiJson({
        'id': '42',
        'hadeeth': 'İnsanların en hayırlısı insanlara faydalı olandır.',
        'reference': 'Câmiu\'s-Sağîr, 11375',
        'attribution': 'Câbir (r.a.)',
        'title': 'İnsanlara Faydalı Olmak',
        'grade': 'Sahih',
      });

      expect(hadith.id, 100042); // offset 100000 + 42
      expect(hadith.text,
          'İnsanların en hayırlısı insanlara faydalı olandır.');
      expect(hadith.source, 'Câmiu\'s-Sağîr, 11375');
      expect(hadith.narrator, 'Câbir (r.a.)');
      expect(hadith.topic, 'İnsanlara Faydalı Olmak');
      expect(hadith.grade, 'Sahih');
    });

    test('id offset prevents collision with local hadiths (1–40)', () {
      final local = Hadith.fromApiJson({'id': '1', 'hadeeth': 'x',
          'reference': '', 'attribution': '', 'title': '', 'grade': null});
      expect(local.id, greaterThan(99999));
    });

    test('handles missing optional fields', () {
      final hadith = Hadith.fromApiJson({
        'id': '0',
        'hadeeth': null,
        'reference': null,
        'attribution': null,
        'title': null,
        'grade': null,
      });
      expect(hadith.text, '');
      expect(hadith.grade, isNull);
    });

    test('trims whitespace from text fields', () {
      final hadith = Hadith.fromApiJson({
        'id': '5',
        'hadeeth': '  Hadis metni  ',
        'reference': '  Bukhari  ',
        'attribution': '  Ebu Hureyre  ',
        'title': '  Başlık  ',
        'grade': 'Sahih',
      });
      expect(hadith.text, 'Hadis metni');
      expect(hadith.source, 'Bukhari');
      expect(hadith.narrator, 'Ebu Hureyre');
      expect(hadith.topic, 'Başlık');
    });
  });

  group('Hadith toJson/fromJson roundtrip (with grade)', () {
    test('grade preserved', () {
      final original = Hadith(
        id: 100042,
        text: 'Test hadis',
        source: 'Bukhari',
        narrator: 'Ebu Hureyre',
        topic: 'Test',
        grade: 'Sahih',
      );
      final json = original.toJson();
      expect(json['grade'], 'Sahih');
    });

    test('null grade omitted from json', () {
      final original = Hadith(
        id: 1,
        text: 'Yerel hadis',
        source: 'Kaynak',
        narrator: 'Ravi',
        topic: 'Konu',
      );
      final json = original.toJson();
      expect(json.containsKey('grade'), isFalse);
    });
  });
}
