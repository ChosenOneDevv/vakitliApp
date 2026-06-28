import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';

class CountdownTimer extends StatefulWidget {
  final String prayerName;
  final DateTime targetTime;

  const CountdownTimer({
    super.key,
    required this.prayerName,
    required this.targetTime,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  // Saniyede bir değişen tek parça. setState yerine ValueNotifier kullanılır;
  // böylece her saniye sadece saat Text'i rebuild olur, gradient/shadow/Column
  // değil.
  final ValueNotifier<String> _formatted = ValueNotifier('00:00:00');

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _updateCountdown();
    }
  }

  void _updateCountdown() {
    final diff = widget.targetTime.difference(DateTime.now());
    final total = diff.isNegative ? Duration.zero : diff;
    final h = total.inHours.toString().padLeft(2, '0');
    final m = total.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = total.inSeconds.remainder(60).toString().padLeft(2, '0');
    _formatted.value = '$h:$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _formatted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGreen,
            AppColors.primaryGreen,
            AppColors.lightGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sonraki Vakit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightGold,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.prayerName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 26,
                ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ValueListenableBuilder<String>(
              valueListenable: _formatted,
              builder: (context, value, child) => Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
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
