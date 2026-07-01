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
      case 'tahajjud':
        return Icons.nightlight_round;
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
              const SizedBox(height: 16),

              // Kalıcı bildirim
              _buildOngoingTile(context, alarmProvider),
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

  Widget _buildOngoingTile(BuildContext context, AlarmProvider alarmProvider) {
    return Container(
      decoration: BoxDecoration(
        color: alarmProvider.ongoingEnabled
            ? AppColors.navy.withValues(alpha: 0.06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alarmProvider.ongoingEnabled
              ? AppColors.navy.withValues(alpha: 0.25)
              : AppColors.darkCream,
          width: alarmProvider.ongoingEnabled ? 1.5 : 0.5,
        ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: alarmProvider.ongoingEnabled
                ? AppColors.navy.withValues(alpha: 0.12)
                : AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.notifications_active_outlined,
            color: alarmProvider.ongoingEnabled ? AppColors.navy : AppColors.gold,
            size: 22,
          ),
        ),
        title: Text(
          'Kalıcı Bildirim',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(
          'Sonraki vakti bildirim çubuğunda göster',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        value: alarmProvider.ongoingEnabled,
        activeTrackColor: AppColors.navy,
        onChanged: (v) => alarmProvider.toggleOngoing(v),
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
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: setting.enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
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
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _getIcon(setting.prayerKey),
                color: setting.enabled ? Theme.of(context).colorScheme.primary : AppColors.gold,
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                : null,
            trailing: Switch.adaptive(
              value: setting.enabled,
              activeTrackColor: Theme.of(context).colorScheme.primary,
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
          if (setting.enabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
              child: _buildModeSelector(context, setting, alarmProvider),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 6, bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: setting.useEzan
                        ? AppColors.gold
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ezan sesi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: setting.useEzan
                              ? AppColors.gold
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight: setting.useEzan
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: setting.useEzan,
                      activeTrackColor: AppColors.gold,
                      onChanged: (v) =>
                          alarmProvider.setAlarmEzan(setting.prayerKey, v),
                    ),
                  ),
                ],
              ),
            ),
            if (setting.effectiveMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 6, bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_add_rounded,
                      size: 16,
                      color: setting.alsoOnTime
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ayrıca vakitte de bildir',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: setting.alsoOnTime
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight: setting.alsoOnTime
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: setting.alsoOnTime,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        onChanged: (v) => alarmProvider.setAlsoOnTime(
                            setting.prayerKey, v),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
        final isCustom = mode == AlarmMode.custom;
        final label = isCustom && isSelected
            ? '${setting.customMinutes} dk önce'
            : (isCustom ? 'Özel…' : mode.label);
        return GestureDetector(
          onTap: () async {
            if (isCustom) {
              _showCustomMinutesDialog(context, setting, alarmProvider);
            } else {
              // setAlarmMode bildirimleri otomatik yeniden kurar.
              await alarmProvider.setAlarmMode(setting.prayerKey, mode);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Text(
              label,
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

  void _showCustomMinutesDialog(
    BuildContext context,
    PrayerAlarmSetting setting,
    AlarmProvider alarmProvider,
  ) {
    final controller =
        TextEditingController(text: '${setting.customMinutes}');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${setting.prayerName} — Özel Süre'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Kaç dakika önce',
            suffixText: 'dk',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final m = int.tryParse(controller.text.trim());
              if (m != null && m >= 0) {
                alarmProvider.setCustomMinutes(setting.prayerKey, m);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
