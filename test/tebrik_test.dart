import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/models/tebrik_card.dart';

void main() {
  group('TebrikCard.fromFirestoreJson', () {
    test('parses all fields', () {
      final card = TebrikCard.fromFirestoreJson('doc1', {
        'order': 3,
        'title': 'Kadir Gecesi',
        'occasion': 'Kadir',
        'imageUrl': 'https://example.com/kadir.jpg',
        'shareText': 'Kadir Geceniz mübarek olsun!',
      });

      expect(card.id, 3);
      expect(card.title, 'Kadir Gecesi');
      expect(card.occasion, 'Kadir');
      expect(card.imageUrl, 'https://example.com/kadir.jpg');
      expect(card.shareText, 'Kadir Geceniz mübarek olsun!');
      expect(card.imagePath, isNull);
    });

    test('falls back occasion to title when occasion missing', () {
      final card = TebrikCard.fromFirestoreJson('doc2', {
        'order': 1,
        'title': 'Cuma Mübarek',
        'imageUrl': null,
        'shareText': 'Cumanız mübarek',
      });
      expect(card.occasion, 'Cuma Mübarek');
    });

    test('handles missing optional fields gracefully', () {
      final card = TebrikCard.fromFirestoreJson('doc3', {});
      expect(card.id, 0);
      expect(card.title, '');
      expect(card.imageUrl, isNull);
      expect(card.shareText, '');
    });
  });

  group('TebrikCard toJson / fromJson roundtrip', () {
    test('local card roundtrip (no imageUrl)', () {
      const original = TebrikCard(
        id: 5,
        title: 'Berat Kandili',
        occasion: 'Berat',
        shareText: 'Berat Kandili mübarek',
        imagePath: 'assets/images/berat.png',
      );
      final json = original.toJson();
      final restored = TebrikCard.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.occasion, original.occasion);
      expect(restored.imagePath, original.imagePath);
      expect(restored.imageUrl, isNull);
    });

    test('network card roundtrip (imageUrl, no imagePath)', () {
      const original = TebrikCard(
        id: 10,
        title: 'Ramazan',
        occasion: 'Ramazan Bayramı',
        shareText: 'Bayramınız mübarek',
        imageUrl: 'https://storage.example.com/ramazan.jpg',
      );
      final json = original.toJson();
      final restored = TebrikCard.fromJson(json);

      expect(restored.imageUrl,
          'https://storage.example.com/ramazan.jpg');
      expect(restored.imagePath, isNull);
    });
  });

  group('TebrikCard.defaults', () {
    test('has 8 cards', () {
      expect(TebrikCard.defaults.length, 8);
    });

    test('all defaults have non-empty title and shareText', () {
      for (final card in TebrikCard.defaults) {
        expect(card.title, isNotEmpty,
            reason: 'id=${card.id} title empty');
        expect(card.shareText, isNotEmpty,
            reason: 'id=${card.id} shareText empty');
      }
    });

    test('all defaults have null imageUrl (local only)', () {
      expect(TebrikCard.defaults.every((c) => c.imageUrl == null), isTrue);
    });
  });
}
