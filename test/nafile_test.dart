import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/nafile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('toggle marks today + counts', () async {
    final p = NafileProvider();
    await p.initialize();
    expect(p.isDoneToday('duha'), false);
    expect(p.todayCount, 0);

    await p.toggleToday('duha');
    expect(p.isDoneToday('duha'), true);
    expect(p.todayCount, 1);
    expect(p.totalFor('duha'), 1);

    await p.toggleToday('duha');
    expect(p.isDoneToday('duha'), false);
    expect(p.totalFor('duha'), 0);
  });

  test('persists across instances', () async {
    final p1 = NafileProvider();
    await p1.initialize();
    await p1.toggleToday('tahajjud');

    final p2 = NafileProvider();
    await p2.initialize();
    expect(p2.isDoneToday('tahajjud'), true);
  });
}
