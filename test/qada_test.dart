import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/qada_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts at zero', () async {
    final p = QadaProvider();
    await p.initialize();
    expect(p.total, 0);
    expect(p.count('fajr'), 0);
  });

  test('increment/decrement and total', () async {
    final p = QadaProvider();
    await p.initialize();
    await p.increment('fajr');
    await p.increment('fajr');
    await p.increment('witr');
    expect(p.count('fajr'), 2);
    expect(p.total, 3);
    await p.decrement('fajr');
    expect(p.count('fajr'), 1);
  });

  test('decrement clamps at zero', () async {
    final p = QadaProvider();
    await p.initialize();
    await p.decrement('isha');
    expect(p.count('isha'), 0);
  });

  test('persists across instances', () async {
    final p1 = QadaProvider();
    await p1.initialize();
    await p1.increment('asr');

    final p2 = QadaProvider();
    await p2.initialize();
    expect(p2.count('asr'), 1);
  });
}
