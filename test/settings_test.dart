import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/services/api_service.dart';
import 'package:vakitli/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Calculation methods', () {
    test('default method is Diyanet (13)', () {
      expect(ApiService.defaultMethod, 13);
      expect(PrayerProvider.calculationMethods[13], contains('Diyanet'));
    });

    test('method map has multiple options', () {
      expect(PrayerProvider.calculationMethods.length, greaterThan(3));
    });

    test('new provider defaults to Diyanet method', () {
      final provider = PrayerProvider();
      expect(provider.calculationMethod, ApiService.defaultMethod);
      expect(provider.calculationMethodName, contains('Diyanet'));
    });
  });

  group('SettingsService.resetAllData', () {
    test('clears all stored keys', () async {
      SharedPreferences.setMockInitialValues({
        'hadith_favorites': '[1,2]',
        'prayer_logs': '{}',
        'calculation_method': 3,
      });
      await SettingsService().resetAllData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('hadith_favorites'), isNull);
      expect(prefs.getString('prayer_logs'), isNull);
      expect(prefs.getInt('calculation_method'), isNull);
    });
  });
}
