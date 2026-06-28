import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/tasbih_profile.dart';
import 'package:vakitli/providers/tasbih_provider.dart';

void main() {
  // HapticFeedback platform kanalı için binding gerekli.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TasbihProfile', () {
    test('progress within a cycle', () {
      final p = TasbihProfile(id: 1, name: 'x', target: 33, count: 11);
      expect(p.progress, closeTo(11 / 33, 0.0001));
    });

    test('full ring at exact multiple of target', () {
      final p = TasbihProfile(id: 1, name: 'x', target: 33, count: 33);
      expect(p.progress, 1.0);
      expect(p.targetReached, true);
    });

    test('targetReached false mid-cycle', () {
      final p = TasbihProfile(id: 1, name: 'x', target: 33, count: 10);
      expect(p.targetReached, false);
    });

    test('copyWith keeps id, overrides fields', () {
      final p = TasbihProfile(id: 7, name: 'a', target: 33);
      final q = p.copyWith(count: 5, total: 5);
      expect(q.id, 7);
      expect(q.count, 5);
      expect(q.total, 5);
      expect(q.name, 'a');
    });
  });

  group('TasbihProvider', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('seeds default profiles on first run', () async {
      final provider = TasbihProvider();
      await provider.initialize();
      expect(provider.profiles.length, 3);
      expect(provider.active, isNotNull);
    });

    test('increment raises count, total and grandTotal', () async {
      final provider = TasbihProvider();
      await provider.initialize();
      await provider.increment();
      await provider.increment();
      expect(provider.active!.count, 2);
      expect(provider.active!.total, 2);
      expect(provider.grandTotal, 2);
    });

    test('resetCurrent zeroes count but keeps total', () async {
      final provider = TasbihProvider();
      await provider.initialize();
      await provider.increment();
      await provider.resetCurrent();
      expect(provider.active!.count, 0);
      expect(provider.active!.total, 1);
    });

    test('addProfile becomes active', () async {
      final provider = TasbihProvider();
      await provider.initialize();
      await provider.addProfile('Estağfirullah', 100);
      expect(provider.active!.name, 'Estağfirullah');
      expect(provider.profiles.length, 4);
    });

    test('cannot delete last profile', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TasbihProvider();
      await provider.initialize();
      // 3 varsayılan -> 2 sil, son kalanı silmeye çalış
      final ids = provider.profiles.map((p) => p.id).toList();
      await provider.deleteProfile(ids[0]);
      await provider.deleteProfile(ids[1]);
      final remaining = provider.profiles.first.id;
      await provider.deleteProfile(remaining);
      expect(provider.profiles.length, 1);
    });
  });
}
