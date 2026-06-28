import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/alarm_settings.dart';
import 'package:vakitli/providers/alarm_provider.dart';

class AlarmSettingsScreen extends StatelessWidget {
  const AlarmSettingsScreen({super.key});

  IconData _getIcon(String prayerKey) {
    switch (prayerKey) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Ayarları'),
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, _) {
          final settings = alarmProvider.allSettings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bilgi kartı
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Her namaz vakti için ayrı ayrı alarm kurabilirsiniz. Alarmlar günlük olarak güncellenir.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Alarm ayarları listesi
              ...settings.map((setting) => _buildAlarmTile(
                    context,
                    setting,
                    alarmProvider,
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlarmTile(
    BuildContext context,
    PrayerAlarmSetting setting,
    AlarmProvider alarmProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: setting.enabled
            ? AppColors.primaryGreen.withValues(alpha: 0.06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: setting.enabled
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : AppColors.darkCream,
          width: setting.enabled ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: setting.enabled
                    ? AppColors.primaryGreen.withValues(alpha: 0.12)
                    : AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _getIcon(setting.prayerKey),
                color: setting.enabled ? AppColors.primaryGreen : AppColors.gold,
                size: 22,
              ),
            ),
            title: Text(
              setting.prayerName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: setting.enabled
                ? Text(
                    setting.mode.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                : null,
            trailing: Switch.adaptive(
              value: setting.enabled,
              activeTrackColor: AppColors.primaryGreen,
              onChanged: (value) async {
                if (value) {
                  final granted = await alarmProvider.requestPermissions();
                  if (!granted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bildirim izni verilmedi. Ayarlardan izin verebilirsiniz.'),
                        ),
                      );
                    }
                    return;
                  }
                }
                // toggleAlarm bildirimleri otomatik yeniden kurar.
                await alarmProvider.toggleAlarm(setting.prayerKey, value);
              },
            ),
          ),
          if (setting.enabled)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
              child: _buildModeSelector(context, setting, alarmProvider),
            ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    PrayerAlarmSetting setting,
    AlarmProvider alarmProvider,
  ) {
    final modes = AlarmMode.values.where((m) => m != AlarmMode.off).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: modes.map((mode) {
        final isSelected = setting.mode == mode;
        return GestureDetector(
          onTap: () async {
            // setAlarmMode bildirimleri otomatik yeniden kurar.
            await alarmProvider.setAlarmMode(setting.prayerKey, mode);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Text(
              mode.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
