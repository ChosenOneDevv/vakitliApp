import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/models/alarm_settings.dart';

class PrayerCard extends StatelessWidget {
  final PrayerEntry entry;
  final bool isNext;
  final PrayerAlarmSetting? alarmSetting;

  const PrayerCard({
    super.key,
    required this.entry,
    this.isNext = false,
    this.alarmSetting,
  });

  IconData _getIcon() {
    switch (entry.icon) {
      case 'fajr':
        return Icons.dark_mode_outlined;
      case 'sunrise':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.bedtime_outlined;
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final alarmOn = alarmSetting != null && alarmSetting!.enabled;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
      decoration: BoxDecoration(
        color: isNext
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Sıradaki vakit için ince vurgu çubuğu.
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              color: isNext ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            _getIcon(),
            size: 21,
            color: isNext ? Theme.of(context).colorScheme.primary : AppColors.lightText,
          ),
          const SizedBox(width: 12),
          Text(
            entry.name,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.5,
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              color: isNext ? Theme.of(context).colorScheme.primary : onSurface,
            ),
          ),
          const Spacer(),
          if (alarmOn)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.notifications_active_rounded,
                  size: 15, color: AppColors.gold.withValues(alpha: 0.9)),
            ),
          Text(
            entry.time,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isNext ? Theme.of(context).colorScheme.primary : onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
