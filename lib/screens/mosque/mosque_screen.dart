import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/mosque.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/services/mosque_service.dart';

class MosqueScreen extends StatefulWidget {
  const MosqueScreen({super.key});

  @override
  State<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends State<MosqueScreen> {
  final MosqueService _service = MosqueService();
  final MapController _mapController = MapController();

  late LatLng _center;
  List<Mosque> _mosques = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final prayer = context.read<PrayerProvider>();
    _center = LatLng(prayer.latitude, prayer.longitude);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.findNearby(
      latitude: _center.latitude,
      longitude: _center.longitude,
    );
    if (mounted) {
      setState(() {
        _mosques = list;
        _loading = false;
      });
    }
  }

  Future<void> _openInMaps(Mosque m) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(m.name,
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(m.distanceLabel, style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.map_rounded, color: Colors.green),
              title: const Text('Google Maps ile Yol Tarifi'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}');
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('Google Maps açılamadı');
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.public_rounded, color: AppColors.navy),
              title: const Text('OpenStreetMap ile Göster'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final uri = Uri.parse(
                    'https://www.openstreetmap.org/?mlat=${m.latitude}&mlon=${m.longitude}#map=18/${m.latitude}/${m.longitude}');
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('OSM açılamadı');
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cami Bulucu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vakitli.vakitli',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location_rounded,
                          color: AppColors.navy, size: 28),
                    ),
                    ..._mosques.map((m) => Marker(
                          point: LatLng(m.latitude, m.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.mosque_rounded,
                              color: AppColors.primaryGreen, size: 28),
                        )),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap katkıda bulunanlar'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (_mosques.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 56, color: AppColors.lightText),
              const SizedBox(height: 12),
              Text(
                'Yakında cami bulunamadı veya bağlantı yok.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _mosques.length,
      itemBuilder: (context, index) {
        final m = _mosques[index];
        return ListTile(
          leading: const Icon(Icons.mosque_rounded,
              color: AppColors.primaryGreen),
          title: Text(m.name),
          subtitle: Text(m.distanceLabel),
          trailing: IconButton(
            icon: const Icon(Icons.directions_rounded, color: AppColors.gold),
            onPressed: () => _openInMaps(m),
          ),
          onTap: () => _mapController.move(
            LatLng(m.latitude, m.longitude),
            16,
          ),
        );
      },
    );
  }
}
