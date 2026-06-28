import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/services/qibla_service.dart';

void main() {
  group('QiblaService', () {
    // İstanbul
    const lat = 41.0082;
    const lng = 28.9784;

    test('qibla direction is in valid range and roughly south-east', () {
      final dir = QiblaService.calculateQiblaDirection(lat, lng);
      expect(dir, greaterThanOrEqualTo(0));
      expect(dir, lessThan(360));
      // İstanbul'dan Kâbe güneydoğu yönünde (~150-160°).
      expect(dir, inInclusiveRange(120, 180));
    });

    test('distance to Kaaba is plausible (~2700 km)', () {
      final d = QiblaService.calculateDistanceToKaaba(lat, lng);
      expect(d, inInclusiveRange(2000, 3500));
    });

    test('distance at Kaaba itself is ~0', () {
      final d = QiblaService.calculateDistanceToKaaba(21.4225, 39.8262);
      expect(d, lessThan(1));
    });
  });
}
