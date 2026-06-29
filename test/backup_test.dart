import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export then import roundtrip preserves values', () async {
    SharedPreferences.setMockInitialValues({
      'calculation_method': 3,
      'dnd_enabled': true,
      'hadith_favorites': '[1,2]',
    });
    final json = await BackupService().export();

    // Veriyi temizle, sonra geri yükle.
    SharedPreferences.setMockInitialValues({});
    final ok = await BackupService().import(json);
    expect(ok, true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('calculation_method'), 3);
    expect(prefs.getBool('dnd_enabled'), true);
    expect(prefs.getString('hadith_favorites'), '[1,2]');
  });

  test('rejects invalid json', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await BackupService().import('not json'), false);
  });

  test('rejects foreign backup', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await BackupService().import('{"app":"other","data":{}}'), false);
  });
}
