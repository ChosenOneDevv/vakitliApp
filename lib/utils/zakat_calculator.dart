/// Zekat hesaplama (saf mantık — test edilebilir).
class ZakatCalculator {
  /// Zekat oranı (%2.5).
  static const double rate = 0.025;

  /// Zekata tabi net servet = varlıklar - borçlar.
  static double netWorth({
    required double cash,
    required double gold,
    required double silver,
    required double tradeGoods,
    required double debts,
  }) {
    final net = cash + gold + silver + tradeGoods - debts;
    return net < 0 ? 0 : net;
  }

  /// Net servet nisabı aşıyorsa zekat = net * %2.5, yoksa 0.
  static double zakatDue({required double netWorth, required double nisab}) {
    if (netWorth < nisab) return 0;
    return netWorth * rate;
  }

  /// Nisaba ulaşıldı mı.
  static bool reachesNisab({required double netWorth, required double nisab}) =>
      netWorth >= nisab;
}
