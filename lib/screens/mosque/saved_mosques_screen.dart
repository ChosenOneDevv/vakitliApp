import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/mosque_geofence_provider.dart';
import 'package:vakitli/services/saved_mosque_service.dart';

class SavedMosquesScreen extends StatelessWidget {
  const SavedMosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Camiler')),
      body: Consumer<MosqueGeofenceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.sensors_rounded,
                    color: AppColors.primaryGreen),
                title: const Text('Camide Sessize Al'),
                subtitle: const Text(
                    'Kayıtlı camilere girince telefon otomatik sessize alınır'),
                value: provider.geofencingEnabled,
                activeTrackColor: AppColors.primaryGreen,
                onChanged: (v) => provider.toggleGeofencing(v),
              ),
              const Divider(),
              if (provider.mosques.isEmpty)
                const Expanded(
                  child: Center(
                    child: Padding(
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
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.mosques.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = provider.mosques[i];
                      return _MosqueTile(
                          mosque: m,
                          onDelete: () => provider.removeMosque(m.id));
                    },
                  ),
                ),
            ],
          );
        },
      ),
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
      leading: const Icon(Icons.mosque_rounded, color: AppColors.primaryGreen),
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
