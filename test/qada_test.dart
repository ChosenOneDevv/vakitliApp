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

  test('setCount sets exact value and clamps negatives', () async {
    final p = QadaProvider();
    await p.initialize();
    await p.setCount('dhuhr', 42);
    expect(p.count('dhuhr'), 42);
    await p.setCount('dhuhr', -5);
    expect(p.count('dhuhr'), 0);
  });

  test('addDays adds to every tracked prayer', () async {
    final p = QadaProvider();
    await p.initialize();
    await p.addDays(3);
    for (final k in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'witr']) {
      expect(p.count(k), 3);
    }
    await p.addDays(0); // no-op
    expect(p.total, 18);
  });

  test('auto-sync does not backfill on first run', () async {
    final p = QadaProvider();
    await p.initialize();
    // İlk çalıştırma sadece tarihi işaretler; geçmiş eklenmez.
    expect(p.total, 0);
  });
}
