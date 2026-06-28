import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/theme_provider.dart';
import 'package:vakitli/services/settings_service.dart';
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
                    leading: const Icon(Icons.location_city_rounded,
                        color: AppColors.primaryGreen),
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
                        : const Icon(Icons.my_location_rounded,
                            color: AppColors.primaryGreen),
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
                    leading: const Icon(Icons.calculate_rounded,
                        color: AppColors.primaryGreen),
                    title: const Text('Hesaplama Metodu'),
                    subtitle: Text(prayer.calculationMethodName),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showMethodDialog(context, prayer),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined,
                        color: AppColors.primaryGreen),
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
            leading: const Icon(Icons.alarm_rounded,
                color: AppColors.primaryGreen),
            title: const Text('Alarm Ayarları'),
            subtitle: const Text('Her vakit için bildirim/alarm'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlarmSettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded,
                color: AppColors.primaryGreen),
            title: const Text('Bildirim İzni'),
            subtitle: const Text('Bildirim iznini iste / kontrol et'),
            onTap: () => _requestPermission(context),
          ),
          const Divider(),

          // --- Genel ---
          const _SectionHeader(title: 'Genel', icon: Icons.tune_rounded),
          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return ListTile(
                leading: const Icon(Icons.brightness_6_rounded,
                    color: AppColors.primaryGreen),
                title: const Text('Tema'),
                subtitle: Text(theme.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemeDialog(context, theme),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded,
                color: AppColors.primaryGreen),
            title: const Text('Uygulamayı Paylaş'),
            onTap: () => Share.share(
              'Vakitli — namaz vakitleri ve İslami yaşam uygulaması.',
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.info_rounded, color: AppColors.primaryGreen),
            title: const Text('Hakkında'),
            subtitle: const Text('Sürüm $_appVersion'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),

          // --- Veri ---
          const _SectionHeader(
              title: 'Veri', icon: Icons.storage_rounded),
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
                    activeColor: AppColors.primaryGreen,
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
      applicationIcon: const Icon(Icons.mosque_rounded,
          color: AppColors.primaryGreen, size: 40),
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
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
