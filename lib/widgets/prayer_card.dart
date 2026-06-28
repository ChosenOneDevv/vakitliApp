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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryGreen.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.5)
            : Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.primaryGreen.withValues(alpha: 0.15)
                : AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIcon(),
            color: isNext ? AppColors.primaryGreen : AppColors.gold,
            size: 24,
          ),
        ),
        title: Text(
          entry.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isNext
                    ? AppColors.primaryGreen
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alarmSetting != null && alarmSetting!.enabled)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
              ),
            Text(
              entry.time,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isNext
                    ? AppColors.primaryGreen
                    : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
            ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sıradaki',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
