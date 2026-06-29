import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/qada_provider.dart';
import 'package:vakitli/services/qada_service.dart';
import 'package:vakitli/utils/qada_calculator.dart';

class QadaScreen extends StatelessWidget {
  const QadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaza Namazları')),
      body: Consumer<QadaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TotalCard(total: provider.total),
              const SizedBox(height: 12),
              _CalculateButton(onTap: () => _openCalculator(context, provider)),
              const SizedBox(height: 16),
              ...QadaService.prayerKeys.map(
                (key) => _QadaRow(prayerKey: key, provider: provider),
              ),
              const SizedBox(height: 12),
              Text(
                'Kıldığın kaza namazını "–" ile düş, borç eklemek için "+" kullan.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCalculator(BuildContext context, QadaProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CalculatorSheet(
        onConfirm: (calc) async {
          await provider.addCalculated(calc);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${calc.total} vakit kaza borcuna eklendi.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _CalculateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CalculateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calculate_rounded),
      label: const Text('Tarihten Hesapla'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ─── Hesaplama bottom sheet ───────────────────────────────────────────────────

class _CalculatorSheet extends StatefulWidget {
  final Future<void> Function(QadaCalculation) onConfirm;

  const _CalculatorSheet({required this.onConfirm});

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  DateTime? _bulughDate;
  DateTime? _startDate;
  bool _isFemale = false;
  int _monthlyHaydDays = 5;
  bool _includeWitr = true;
  QadaCalculation? _result;
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_rounded, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Kaza Borcu Hesapla',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _includeWitr,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) => setState(() {
                    _includeWitr = v ?? true;
                    _result = null;
                  }),
                ),
                const Text('Vitiri dahil et'),
              ],
            ),
            const SizedBox(height: 12),

            // Buluğ tarihi
            _DateField(
              label: 'Buluğ tarihi',
              value: _bulughDate,
              hint: 'Seç',
              onTap: () => _pickDate(
                context,
                initial: _bulughDate ?? DateTime(2005),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
                onPicked: (d) => setState(() {
                  _bulughDate = d;
                  _result = null;
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Namaza başlama tarihi
            _DateField(
              label: 'Namaza başlama tarihi',
              value: _startDate,
              hint: 'Seç',
              onTap: () => _pickDate(
                context,
                initial: _startDate ?? DateTime.now(),
                firstDate: _bulughDate ?? DateTime(1930),
                lastDate: DateTime.now(),
                onPicked: (d) => setState(() {
                  _startDate = d;
                  _result = null;
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Cinsiyet
            Row(
              children: [
                const Text('Cinsiyet:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Erkek'),
                  selected: !_isFemale,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                      color: !_isFemale ? AppColors.white : null),
                  onSelected: (_) => setState(() {
                    _isFemale = false;
                    _result = null;
                  }),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Kadın'),
                  selected: _isFemale,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                      color: _isFemale ? AppColors.white : null),
                  onSelected: (_) => setState(() {
                    _isFemale = true;
                    _result = null;
                  }),
                ),
              ],
            ),

            // Hayız günü (kadın)
            if (_isFemale) ...[
              const SizedBox(height: 12),
              Text(
                'Aylık ortalama hayız süresi: $_monthlyHaydDays gün',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: _monthlyHaydDays.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primaryGreen,
                label: '$_monthlyHaydDays gün',
                onChanged: (v) => setState(() {
                  _monthlyHaydDays = v.round();
                  _result = null;
                }),
              ),
              Text(
                'Hayızlı günlerde farz ve vitir borcu oluşmaz.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.lightText),
              ),
            ],

            const SizedBox(height: 20),

            // Hesapla butonu
            if (_result == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCalculate ? _calculate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Hesapla'),
                ),
              ),

            // Sonuç
            if (_result != null) ...[
              _ResultTable(result: _result!, includeWitr: _includeWitr),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _result = null),
                      child: const Text('Düzelt'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirming ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                      ),
                      child: _confirming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white),
                            )
                          : const Text('Borçlara Ekle'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _canCalculate => _bulughDate != null && _startDate != null;

  void _calculate() {
    if (!_canCalculate) return;
    final calc = QadaCalculator.calculate(
      bulughDate: _bulughDate!,
      prayerStartDate: _startDate!,
      isViterWajib: _includeWitr,
      monthlyHaydDays: _isFemale ? _monthlyHaydDays : 0,
    );
    setState(() => _result = calc);
  }

  Future<void> _confirm() async {
    if (_result == null) return;
    setState(() => _confirming = true);
    await widget.onConfirm(_result!);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primaryGreen,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

}

// ─── Yardımcı widget'lar ──────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  static final _fmt = DateFormat('dd.MM.yyyy', 'tr_TR');

  const _DateField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null ? _fmt.format(value!) : hint,
          style: value == null
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightText)
              : null,
        ),
      ),
    );
  }
}

class _ResultTable extends StatelessWidget {
  final QadaCalculation result;
  final bool includeWitr;

  const _ResultTable({required this.result, required this.includeWitr});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Sabah', result.fajr),
      ('Öğle', result.dhuhr),
      ('İkindi', result.asr),
      ('Akşam', result.maghrib),
      ('Yatsı', result.isha),
      if (includeWitr) ('Vitir', result.witr),
    ];

    return Card(
      color: AppColors.primaryGreen.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesaplanan borç',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1),
                    Text(
                      '${r.$2} vakit',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toplam',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${result.total} vakit',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.gold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mevcut widget'lar ────────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final int total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '$total',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam kaza borcu',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.lightGold),
          ),
        ],
      ),
    );
  }
}

class _QadaRow extends StatelessWidget {
  final String prayerKey;
  final QadaProvider provider;

  const _QadaRow({required this.prayerKey, required this.provider});

  @override
  Widget build(BuildContext context) {
    final count = provider.count(prayerKey);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                QadaService.prayerNames[prayerKey]!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: count > 0 ? AppColors.primaryGreen : AppColors.lightText,
              onPressed: count > 0 ? () => provider.decrement(prayerKey) : null,
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.gold,
              onPressed: () => provider.increment(prayerKey),
            ),
          ],
        ),
      ),
    );
  }
}
