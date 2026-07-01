import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';

class CountdownTimer extends StatefulWidget {
  final String prayerName;
  final DateTime targetTime;

  /// Önceki vakitten sonraki vakte geçen oran (0..1) — ilerleme çubuğu.
  final double progress;

  const CountdownTimer({
    super.key,
    required this.prayerName,
    required this.targetTime,
    this.progress = 0,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
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
    final timeStr =
        '${widget.targetTime.hour.toString().padLeft(2, '0')}:${widget.targetTime.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SONRAKİ VAKİT',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGold.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.prayerName,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: _formatted,
            builder: (context, value, child) => Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.white,
                fontSize: 52,
                height: 1.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.progress.clamp(0, 1),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
