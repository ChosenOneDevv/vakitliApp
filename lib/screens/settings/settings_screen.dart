import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/hayd_provider.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/dnd_provider.dart';
import 'package:vakitli/providers/profile_provider.dart';
import 'package:vakitli/providers/theme_provider.dart';
import 'package:vakitli/services/settings_service.dart';
import 'package:vakitli/services/backup_service.dart';
import 'package:vakitli/screens/alarm/alarm_settings_screen.dart';
import 'package:vakitli/screens/location/city_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '0.1.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          // --- Konum ---
          const _SectionHeader(title: 'Konum', icon: Icons.location_on_rounded),
          Consumer<LocationProvider>(
            builder: (context, location, child) {
              final prayer = context.read<PrayerProvider>();
              final cityName =
                  location.currentLocation?.cityName ?? prayer.locationName;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.location_city_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Şehir'),
                    subtitle: Text(cityName),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CitySelectionScreen()),
                    ),
                  ),
                  ListTile(
                    leading: location.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.my_location_rounded,
                            color: Theme.of(context).colorScheme.primary),
                    title: const Text('Konumu otomatik bul'),
                    subtitle: const Text('GPS ile mevcut konumu kullan'),
                    onTap: location.isLoading
                        ? null
                        : () => _detectLocation(context),
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // --- Namaz Vakitleri ---
          const _SectionHeader(
              title: 'Namaz Vakitleri', icon: Icons.mosque_rounded),
          Consumer<PrayerProvider>(
            builder: (context, prayer, child) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.calculate_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Hesaplama Metodu'),
                    subtitle: Text(prayer.calculationMethodName),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showMethodDialog(context, prayer),
                  ),
                  ListTile(
                    leading: Icon(Icons.public_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Yüksek Enlem Kuralı'),
                    subtitle: Text(prayer.latitudeRuleName),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showChoiceDialog(
                      context,
                      title: 'Yüksek Enlem Kuralı',
                      options: PrayerProvider.latitudeRules,
                      current: prayer.latitudeAdjustment,
                      onSelect: prayer.setLatitudeAdjustment,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_month_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Hicri Tarih Ofseti'),
                    subtitle: Text(_hijriLabel(prayer.hijriAdjustment)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          onPressed: prayer.hijriAdjustment > -2
                              ? () => prayer.setHijriAdjustment(
                                  prayer.hijriAdjustment - 1)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          onPressed: prayer.hijriAdjustment < 2
                              ? () => prayer.setHijriAdjustment(
                                  prayer.hijriAdjustment + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // --- Bildirimler ---
          const _SectionHeader(
              title: 'Bildirimler', icon: Icons.notifications_rounded),
          ListTile(
            leading: Icon(Icons.alarm_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Alarm Ayarları'),
            subtitle: const Text('Her vakit için bildirim/alarm'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlarmSettingsScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Bildirim İzni'),
            subtitle: const Text('Bildirim iznini iste / kontrol et'),
            onTap: () => _requestPermission(context),
          ),
          Consumer<DndProvider>(
            builder: (context, dnd, child) {
              return Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.do_not_disturb_on_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Namaz Vaktinde Sessiz'),
                    subtitle: Text(dnd.hasAccess
                        ? 'Vakit girince ${dnd.durationMinutes} dk sessize alır'
                        : 'İzin gerekli — dokunup ver'),
                    value: dnd.enabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) async {
                      if (value && !dnd.hasAccess) {
                        await dnd.openSettings();
                        return;
                      }
                      await dnd.setEnabled(value);
                    },
                  ),
                  if (dnd.enabled && dnd.hasAccess)
                    ListTile(
                      leading: Icon(Icons.timer_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      title: const Text('Sessiz Süresi'),
                      subtitle: Text('${dnd.durationMinutes} dakika'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showDurationDialog(context, dnd),
                    ),
                ],
              );
            },
          ),
          const Divider(),

          // --- Profil ---
          const _SectionHeader(title: 'Profil', icon: Icons.person_rounded),
          Consumer<ProfileProvider>(
            builder: (context, profile, child) {
              return ListTile(
                leading: Icon(Icons.wc_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Cinsiyet'),
                subtitle: Text(profile.isFemale ? 'Kadın' : 'Erkek'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showGenderDialog(context, profile),
              );
            },
          ),
          Consumer<HaydProvider>(
            builder: (context, hayd, child) {
              return Consumer<ProfileProvider>(
                builder: (context, profile, child) {
                  if (!profile.isFemale) return const SizedBox.shrink();
                  return ListTile(
                    leading: Icon(Icons.water_drop_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Hayız Takip'),
                    subtitle: Text('${hayd.records.length} kayıt · ${hayd.totalHaydDays} gün'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // FemaleScreen'e yönlendir — apps'ten de açılabilir
                    },
                  );
                },
              );
            },
          ),
          const Divider(),

          // --- Genel ---
          const _SectionHeader(title: 'Genel', icon: Icons.tune_rounded),
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.brightness_6_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Tema'),
                    subtitle: Text(theme.label),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showThemeDialog(context, theme),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Renk Teması'),
                    subtitle: Text(theme.preset.label),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPresetDialog(context, theme),
                  ),
                  SwitchListTile(
                    secondary: Icon(Icons.palette_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Material You Renkleri'),
                    subtitle: const Text(
                        'Cihaz duvar kağıdı renklerini kullan (Android 12+)'),
                    value: theme.useDynamicColor,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    onChanged: theme.setDynamicColor,
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.share_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Uygulamayı Paylaş'),
            onTap: () => Share.share(
              'Vakitli — namaz vakitleri ve İslami yaşam uygulaması.',
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.info_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Hakkında'),
            subtitle: const Text('Sürüm $_appVersion'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),

          // --- Veri ---
          const _SectionHeader(
              title: 'Veri', icon: Icons.storage_rounded),
          ListTile(
            leading: Icon(Icons.upload_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Yedeği Dışa Aktar'),
            subtitle: const Text('Tüm veriyi JSON olarak paylaş'),
            onTap: () => _exportBackup(context),
          ),
          ListTile(
            leading: Icon(Icons.download_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Yedekten İçe Aktar'),
            subtitle: const Text('JSON yedeği yapıştırarak geri yükle'),
            onTap: () => _importBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text('Tüm Verileri Sıfırla',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Favoriler, takip, tesbih, ayarlar silinir'),
            onTap: () => _confirmReset(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showGenderDialog(BuildContext context, ProfileProvider profile) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cinsiyet'),
        content: RadioGroup<Gender>(
          groupValue: profile.gender,
          onChanged: (value) {
            if (value != null) profile.setGender(value);
            Navigator.of(dialogContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<Gender>(
                value: Gender.male,
                title: Text('Erkek'),
              ),
              RadioListTile<Gender>(
                value: Gender.female,
                title: Text('Kadın'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tema'),
          content: RadioGroup<ThemeMode>(
            groupValue: theme.themeMode,
            onChanged: (mode) {
              if (mode != null) theme.setThemeMode(mode);
              Navigator.of(dialogContext).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RadioListTile<ThemeMode>(
                    value: ThemeMode.system, title: Text('Sistem')),
                RadioListTile<ThemeMode>(
                    value: ThemeMode.light, title: Text('Açık')),
                RadioListTile<ThemeMode>(
                    value: ThemeMode.dark, title: Text('Koyu')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPresetDialog(BuildContext context, ThemeProvider theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renk Teması'),
        content: RadioGroup<AppThemePreset>(
          groupValue: theme.preset,
          onChanged: (v) {
            if (v != null) theme.setPreset(v);
            Navigator.of(dialogContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemePreset.values.map((preset) {
              return RadioListTile<AppThemePreset>(
                value: preset,
                title: Text(preset.label),
                secondary: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showChoiceDialog(
    BuildContext context, {
    required String title,
    required Map<int, String> options,
    required int current,
    required void Function(int) onSelect,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<int>(
              groupValue: current,
              onChanged: (value) {
                if (value != null) onSelect(value);
                Navigator.of(dialogContext).pop();
              },
              child: ListView(
                shrinkWrap: true,
                children: options.entries
                    .map((e) => RadioListTile<int>(
                          value: e.key,
                          title: Text(e.value),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _showDurationDialog(BuildContext context, DndProvider dnd) {
    const options = [5, 10, 15, 20, 30];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sessiz Süresi'),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<int>(
            groupValue: dnd.durationMinutes,
            onChanged: (value) {
              if (value != null) dnd.setDuration(value);
              Navigator.of(dialogContext).pop();
            },
            child: ListView(
              shrinkWrap: true,
              children: options
                  .map((m) => RadioListTile<int>(
                        value: m,
                        title: Text('$m dakika'),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _hijriLabel(int adjustment) {
    if (adjustment == 0) return 'Ofset yok';
    return '${adjustment > 0 ? '+' : ''}$adjustment gün';
  }

  Future<void> _detectLocation(BuildContext context) async {
    final location = context.read<LocationProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await location.detectCurrentLocation();
    if (ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Konum güncellendi: ${location.currentLocation?.cityName ?? ''}'),
        ),
      );
      return;
    }

    // Başarısız: izin kalıcı reddedildiyse Ayarlar'a yönlendir.
    final permanentlyDenied = await location.isPermanentlyDenied();
    messenger.showSnackBar(
      SnackBar(
        content: Text(location.error ?? 'Konum alınamadı.'),
        action: permanentlyDenied
            ? SnackBarAction(
                label: 'Ayarlar',
                onPressed: location.openAppSettings,
              )
            : null,
      ),
    );
  }

  void _showMethodDialog(BuildContext context, PrayerProvider prayer) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hesaplama Metodu'),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<int>(
              groupValue: prayer.calculationMethod,
              onChanged: (value) {
                if (value != null) prayer.setCalculationMethod(value);
                Navigator.of(dialogContext).pop();
              },
              child: ListView(
                shrinkWrap: true,
                children: PrayerProvider.calculationMethods.entries.map((e) {
                  return RadioListTile<int>(
                    value: e.key,
                    title: Text(e.value),
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final alarm = context.read<AlarmProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final granted = await alarm.requestPermissions();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            granted ? 'Bildirim izni verildi.' : 'Bildirim izni reddedildi.'),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vakitli',
      applicationVersion: _appVersion,
      applicationIcon: Icon(Icons.mosque_rounded,
          color: Theme.of(context).colorScheme.primary, size: 40),
      children: const [
        SizedBox(height: 12),
        Text(
          'Namaz vakitlerini takip eden, alarm/bildirim yöneten, '
          'günlük hadis ve dua sunan İslami yaşam uygulaması.',
        ),
        SizedBox(height: 12),
        Text('Vakitler Aladhan API üzerinden hesaplanır.'),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final json = await BackupService().export();
    await Share.share(json, subject: 'Vakitli Yedek');
  }

  void _importBackup(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yedekten İçe Aktar'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'JSON yedeğini buraya yapıştırın',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await BackupService().import(controller.text.trim());
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Yedek geri yüklendi. Uygulamayı yeniden başlatın.'
                      : 'Geçersiz yedek verisi.'),
                ),
              );
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tüm verileri sıfırla?'),
        content: const Text(
          'Favoriler, namaz takip kayıtları, tesbih sayaçları, alarm ve '
          'konum ayarları kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await SettingsService().resetAllData();
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                      'Veriler silindi. Değişiklikler için uygulamayı yeniden başlatın.'),
                ),
              );
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
