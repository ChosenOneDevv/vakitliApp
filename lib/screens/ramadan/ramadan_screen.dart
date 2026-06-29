import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/fasting_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ramazan')),
      body: Consumer<PrayerProvider>(
        builder: (context, prayer, child) {
          final today = prayer.todayPrayer;
          if (today == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final now = DateTime.now();
          final imsak = today.entries.firstWhere((e) => e.icon == 'fajr');
          final iftar = today.entries.firstWhere((e) => e.icon == 'maghrib');
          final imsakDt = imsak.timeOn(now);
          final iftarDt = iftar.timeOn(now);

          String label;
          DateTime target;
          if (now.isBefore(imsakDt)) {
            label = 'Sahura (İmsak) Kalan';
            target = imsakDt;
          } else if (now.isBefore(iftarDt)) {
            label = 'İftara Kalan';
            target = iftarDt;
          } else {
            label = 'Sahura (İmsak) Kalan';
            // Yarının imsak'ı (varsa); yoksa bugünün +1 gün.
            final tImsak = prayer.tomorrowPrayer?.entries
                .firstWhere((e) => e.icon == 'fajr');
            target = tImsak?.timeOn(now.add(const Duration(days: 1))) ??
                imsakDt.add(const Duration(days: 1));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CountdownCard(label: label, target: target),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      title: 'Sahur (İmsak)',
                      time: imsak.time,
                      icon: Icons.bedtime_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeCard(
                      title: 'İftar (Akşam)',
                      time: iftar.time,
                      icon: Icons.restaurant_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _FastingCard(),
            ],
          );
        },
      ),
    );
  }
}

class _CountdownCard extends StatefulWidget {
  final String label;
  final DateTime target;

  const _CountdownCard({required this.label, required this.target});

  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  Timer? _timer;
  final ValueNotifier<String> _text = ValueNotifier('00:00:00');

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.target.difference(DateTime.now());
    final t = diff.isNegative ? Duration.zero : diff;
    _text.value =
        '${t.inHours.toString().padLeft(2, '0')}:${t.inMinutes.remainder(60).toString().padLeft(2, '0')}:${t.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
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
            widget.label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.lightGold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          RepaintBoundary(
            child: ValueListenableBuilder<String>(
              valueListenable: _text,
              builder: (context, value, child) => Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _TimeCard(
      {required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 26),
            const SizedBox(height: 8),
            Text(time,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryGreen,
                    )),
            const SizedBox(height: 2),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FastingCard extends StatelessWidget {
  const _FastingCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingProvider>(
      builder: (context, fasting, child) {
        if (fasting.isLoading) {
          return const SizedBox.shrink();
        }
        final fasted = fasting.isFastedToday;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                          label: 'Bu Ay', value: '${fasting.thisMonthCount}'),
                    ),
                    Expanded(
                      child:
                          _Stat(label: 'Toplam', value: '${fasting.totalDays}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: fasting.toggleToday,
                    icon: Icon(fasted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined),
                    label: Text(
                        fasted ? 'Bugün oruç tutuldu ✓' : 'Bugün oruç tuttum'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          fasted ? AppColors.lightGreen : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
