import 'package:flutter/material.dart';
import 'package:vakitli/services/mosque_geofence_service.dart';
import 'package:vakitli/services/saved_mosque_service.dart';

class MosqueGeofenceProvider extends ChangeNotifier {
  final SavedMosqueService _saveService = SavedMosqueService();
  final MosqueGeofenceService _geoService = MosqueGeofenceService();

  List<SavedMosque> _mosques = [];
  bool _geofencingEnabled = false;
  bool _isLoading = false;

  List<SavedMosque> get mosques => _mosques;
  bool get geofencingEnabled => _geofencingEnabled;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _mosques = await _saveService.loadAll();
    _isLoading = false;
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
