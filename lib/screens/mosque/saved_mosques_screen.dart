import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/dnd_log_entry.dart';
import 'package:vakitli/providers/mosque_geofence_provider.dart';
import 'package:vakitli/services/saved_mosque_service.dart';

class SavedMosquesScreen extends StatefulWidget {
  const SavedMosquesScreen({super.key});

  @override
  State<SavedMosquesScreen> createState() => _SavedMosquesScreenState();
}

class _SavedMosquesScreenState extends State<SavedMosquesScreen> {
  @override
  void initState() {
    super.initState();
    // Geçmiş + pil optimizasyonu durumunu tazele.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MosqueGeofenceProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Camiler')),
      body: Consumer<MosqueGeofenceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              SwitchListTile(
                secondary: Icon(Icons.sensors_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Camide Sessize Al'),
                subtitle: const Text(
                    'Kayıtlı camilere girince telefon otomatik sessize alınır'),
                value: provider.geofencingEnabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => provider.toggleGeofencing(v),
              ),
              if (provider.geofencingEnabled && provider.batteryOptimized)
                _BatteryWarningCard(
                  onFix: () => provider.requestBatteryExemption(),
                ),
              const Divider(),
              if (provider.mosques.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mosque_rounded,
                          size: 64, color: AppColors.lightText),
                      SizedBox(height: 16),
                      Text(
                        'Henüz kayıtlı cami yok.\nCami bulucudan kaydet butonuna basın.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...provider.mosques.map(
                  (m) => _MosqueTile(
                      mosque: m, onDelete: () => provider.removeMosque(m.id)),
                ),
              if (provider.logs.isNotEmpty)
                _LogSection(
                  logs: provider.logs,
                  onClear: () => provider.clearLogs(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BatteryWarningCard extends StatelessWidget {
  final VoidCallback onFix;

  const _BatteryWarningCard({required this.onFix});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      color: AppColors.gold.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.battery_alert_rounded, color: AppColors.gold),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Arka planda kesintisiz çalışması için uygulamayı pil '
                'optimizasyonundan muaf tutun.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onFix,
              child: const Text('İzin Ver'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogSection extends StatelessWidget {
  final List<DndLogEntry> logs;
  final VoidCallback onClear;

  const _LogSection({required this.logs, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, HH:mm', 'tr_TR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Text('Sessize Alma Geçmişi',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: const Text('Temizle',
                    style: TextStyle(color: AppColors.lightText)),
              ),
            ],
          ),
        ),
        ...logs.map(
          (log) => ListTile(
            dense: true,
            leading: Icon(
              log.silenced
                  ? Icons.notifications_off_rounded
                  : Icons.notifications_active_rounded,
              color:
                  log.silenced ? Theme.of(context).colorScheme.primary : AppColors.lightText,
            ),
            title: Text(log.mosqueName),
            subtitle: Text(log.silenced ? 'Sessize alındı' : 'Ses açıldı'),
            trailing: Text(
              fmt.format(log.time),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _MosqueTile extends StatelessWidget {
  final SavedMosque mosque;
  final VoidCallback onDelete;

  const _MosqueTile({required this.mosque, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary),
      title: Text(mosque.name),
      subtitle: Text(
        '${mosque.latitude.toStringAsFixed(5)}, ${mosque.longitude.toStringAsFixed(5)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Camiyi Kaldır'),
            content: Text('"${mosque.name}" kayıtlı camilerden kaldırılsın mı?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onDelete();
                },
                child: const Text('Kaldır',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
