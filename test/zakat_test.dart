import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/utils/zakat_calculator.dart';

void main() {
  group('ZakatCalculator', () {
    test('netWorth subtracts debts', () {
      final net = ZakatCalculator.netWorth(
        cash: 10000,
        gold: 5000,
        silver: 0,
        tradeGoods: 2000,
        debts: 3000,
      );
      expect(net, 14000);
    });

    test('netWorth never negative', () {
      final net = ZakatCalculator.netWorth(
        cash: 1000,
        gold: 0,
        silver: 0,
        tradeGoods: 0,
        debts: 5000,
      );
      expect(net, 0);
    });

    test('zakat is 2.5% when above nisab', () {
      final zakat = ZakatCalculator.zakatDue(netWorth: 100000, nisab: 50000);
      expect(zakat, 2500);
    });

    test('no zakat below nisab', () {
      expect(ZakatCalculator.zakatDue(netWorth: 40000, nisab: 50000), 0);
      expect(
          ZakatCalculator.reachesNisab(netWorth: 40000, nisab: 50000), false);
    });

    test('exactly at nisab is due', () {
      expect(ZakatCalculator.reachesNisab(netWorth: 50000, nisab: 50000), true);
      expect(ZakatCalculator.zakatDue(netWorth: 50000, nisab: 50000), 1250);
    });
  });
}
