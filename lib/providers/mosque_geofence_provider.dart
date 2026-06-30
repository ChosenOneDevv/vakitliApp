import 'package:flutter/material.dart';
import 'package:vakitli/models/dnd_log_entry.dart';
import 'package:vakitli/services/dnd_log_service.dart';
import 'package:vakitli/services/dnd_service.dart';
import 'package:vakitli/services/mosque_geofence_service.dart';
import 'package:vakitli/services/saved_mosque_service.dart';

class MosqueGeofenceProvider extends ChangeNotifier {
  final SavedMosqueService _saveService = SavedMosqueService();
  final MosqueGeofenceService _geoService = MosqueGeofenceService();
  final DndLogService _logService = DndLogService();
  final DndService _dnd = DndService();

  List<SavedMosque> _mosques = [];
  List<DndLogEntry> _logs = [];
  bool _geofencingEnabled = false;
  bool _batteryOptimized = true;
  bool _isLoading = false;

  List<SavedMosque> get mosques => _mosques;
  List<DndLogEntry> get logs => List.unmodifiable(_logs);
  bool get geofencingEnabled => _geofencingEnabled;

  /// Uygulama pil optimizasyonuna tabi mi? (true → arka plan riski var)
  bool get batteryOptimized => _batteryOptimized;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _mosques = await _saveService.loadAll();
    _logs = await _logService.load();
    _batteryOptimized = !await _dnd.isIgnoringBatteryOptimizations();
    _isLoading = false;
    notifyListeners();
  }

  /// Geçmiş ve pil durumu güncellenir (ekran açılışında çağrılır).
  Future<void> refresh() async {
    _logs = await _logService.load();
    _batteryOptimized = !await _dnd.isIgnoringBatteryOptimizations();
    notifyListeners();
  }

  /// Pil optimizasyonu muafiyeti ister; sonra durumu tazeler.
  Future<void> requestBatteryExemption() async {
    await _dnd.requestIgnoreBatteryOptimizations();
    _batteryOptimized = !await _dnd.isIgnoringBatteryOptimizations();
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await _logService.clear();
    _logs = [];
    notifyListeners();
  }

  Future<void> addMosque(SavedMosque mosque) async {
    await _saveService.add(mosque);
    _mosques = await _saveService.loadAll();
    notifyListeners();
    if (_geofencingEnabled) {
      await _geoService.updateRegions(_mosques);
    }
  }

  Future<void> removeMosque(String id) async {
    await _saveService.remove(id);
    _mosques = await _saveService.loadAll();
    notifyListeners();
    if (_geofencingEnabled) {
      await _geoService.updateRegions(_mosques);
    }
  }

  Future<bool> isSaved(String id) => _saveService.isSaved(id);

  Future<void> toggleGeofencing(bool value) async {
    _geofencingEnabled = value;
    notifyListeners();
    if (value) {
      await _geoService.start(_mosques);
    } else {
      await _geoService.stop();
    }
  }
}
