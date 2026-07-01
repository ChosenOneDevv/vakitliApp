import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/utils/zakat_calculator.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cash = TextEditingController();
  final _gold = TextEditingController();
  final _silver = TextEditingController();
  final _trade = TextEditingController();
  final _debts = TextEditingController();
  final _nisab = TextEditingController();

  double _net = 0;
  double _zakat = 0;
  bool _reaches = false;
  bool _calculated = false;

  final _fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  void dispose() {
    for (final c in [_cash, _gold, _silver, _trade, _debts, _nisab]) {
      c.dispose();
    }
    super.dispose();
  }

  double _val(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void _calculate() {
    final net = ZakatCalculator.netWorth(
      cash: _val(_cash),
      gold: _val(_gold),
      silver: _val(_silver),
      tradeGoods: _val(_trade),
      debts: _val(_debts),
    );
    final nisab = _val(_nisab);
    setState(() {
      _net = net;
      _reaches = ZakatCalculator.reachesNisab(netWorth: net, nisab: nisab);
      _zakat = ZakatCalculator.zakatDue(netWorth: net, nisab: nisab);
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zekat Hesaplayıcı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_cash, 'Nakit / Mevduat', Icons.payments_rounded),
          _field(_gold, 'Altın Değeri', Icons.diamond_rounded),
          _field(_silver, 'Gümüş Değeri', Icons.workspace_premium_rounded),
          _field(_trade, 'Ticaret Malı', Icons.storefront_rounded),
          _field(_debts, 'Borçlar (çıkarılır)', Icons.money_off_rounded),
          const Divider(height: 28),
          _field(_nisab, 'Nisab (eşik, ₺)', Icons.straighten_rounded),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Hesapla'),
            ),
          ),
          const SizedBox(height: 16),
          if (_calculated) _result(context),
          const SizedBox(height: 8),
          Text(
            'Zekat oranı %2.5\'tir. Nisab, sahip olunan altın/gümüş değerine göre '
            'belirlenir; güncel nisab tutarını girmeniz gerekir. Bu araç '
            'bilgilendirme amaçlıdır.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _result(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Net Zekata Tabi Servet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightGold)),
          Text(_fmt.format(_net),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                  )),
          const SizedBox(height: 12),
          if (_reaches) ...[
            Text('Ödenecek Zekat',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.lightGold)),
            Text(_fmt.format(_zakat),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    )),
          ] else
            Text(
              'Servet nisabın altında — zekat gerekmez.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.white),
            ),
        ],
      ),
    );
  }
}
