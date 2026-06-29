import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/dnd_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults: disabled, 15 dk', () async {
    final p = DndProvider();
    await p.initialize();
    expect(p.enabled, false);
    expect(p.durationMinutes, 15);
  });

  test('enabled persists', () async {
    final p1 = DndProvider();
    await p1.initialize();
    await p1.setEnabled(true);

    final p2 = DndProvider();
    await p2.initialize();
    expect(p2.enabled, true);
  });

  test('duration persists', () async {
    final p1 = DndProvider();
    await p1.initialize();
    await p1.setDuration(30);

    final p2 = DndProvider();
    await p2.initialize();
    expect(p2.durationMinutes, 30);
  });
}
