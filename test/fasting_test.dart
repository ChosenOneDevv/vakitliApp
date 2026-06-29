import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/fasting_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('toggle today marks fasted + count', () async {
    final p = FastingProvider();
    await p.initialize();
    expect(p.isFastedToday, false);
    expect(p.totalDays, 0);

    await p.toggleToday();
    expect(p.isFastedToday, true);
    expect(p.totalDays, 1);
    expect(p.thisMonthCount, 1);

    await p.toggleToday();
    expect(p.isFastedToday, false);
    expect(p.totalDays, 0);
  });

  test('persists across instances', () async {
    final p1 = FastingProvider();
    await p1.initialize();
    await p1.toggleToday();

    final p2 = FastingProvider();
    await p2.initialize();
    expect(p2.isFastedToday, true);
  });
}
