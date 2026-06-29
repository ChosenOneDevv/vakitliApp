import 'package:flutter/foundation.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:vakitli/services/dnd_service.dart';
import 'package:vakitli/services/saved_mosque_service.dart';

class MosqueGeofenceService {
  final DndService _dnd = DndService();
  bool _running = false;

  Future<void> start(List<SavedMosque> mosques) async {
    if (_running) return;
    if (mosques.isEmpty) return;

    Geofencing.instance.setup(
      interval: 5000,
      accuracy: 100,
      statusChangeDelay: 10000,
      printsDebugLog: kDebugMode,
    );

    Geofencing.instance.addGeofenceStatusChangedListener(_onStatus);

    final regions = mosques.map((m) => GeofenceRegion.circular(
          id: m.id,
          data: m.name,
          center: LatLng(m.latitude, m.longitude),
          radius: 100,
        ));

    await Geofencing.instance.start(regions: regions.toSet());
    _running = true;
    debugPrint('MosqueGeofenceService başlatıldı: ${mosques.length} cami');
  }

  Future<void> stop() async {
    if (!_running) return;
    Geofencing.instance.removeGeofenceStatusChangedListener(_onStatus);
    await Geofencing.instance.stop();
    _running = false;
  }

  Future<void> updateRegions(List<SavedMosque> mosques) async {
    await stop();
    await start(mosques);
  }

  Future<void> _onStatus(
    GeofenceRegion region,
    GeofenceStatus status,
    dynamic location,
  ) async {
    if (status == GeofenceStatus.enter) {
      await _dnd.setSilent(true);
      debugPrint('Camiye girildi: ${region.data} — sessize alındı');
    } else if (status == GeofenceStatus.exit) {
      await _dnd.setSilent(false);
      debugPrint('Camiden çıkıldı: ${region.data} — ses açıldı');
    }
  }

  bool get isRunning => _running;
}
