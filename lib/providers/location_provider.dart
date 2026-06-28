import 'package:flutter/material.dart';
import 'package:vakitli/data/turkey_cities.dart';
import 'package:vakitli/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;
  List<CityData> _filteredCities = List.from(turkeyCities);

  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CityData> get filteredCities => _filteredCities;
  bool get hasLocation => _currentLocation != null;

  Future<void> loadSavedLocation() async {
    final saved = await _locationService.getSavedLocation();
    if (saved != null) {
      _currentLocation = saved;
      notifyListeners();
    }
  }

  Future<bool> detectCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Konum alınamadı. Konum izni verildiğinden ve GPS\'in açık olduğundan emin olun.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Konum hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> selectCity(CityData city) async {
    final data = LocationData(
      latitude: city.latitude,
      longitude: city.longitude,
      cityName: city.name,
    );
    _currentLocation = data;
    _error = null;
    await _locationService.saveLocation(data);
    notifyListeners();
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      _filteredCities = List.from(turkeyCities);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredCities = turkeyCities
          .where((city) => city.name.toLowerCase().contains(lowerQuery))
          .toList();
    }
    notifyListeners();
  }

  void resetFilter() {
    _filteredCities = List.from(turkeyCities);
    notifyListeners();
  }

  /// Konum izni kalıcı reddedildi mi.
  Future<bool> isPermanentlyDenied() => _locationService.isPermanentlyDenied();

  /// Cihaz uygulama ayarlarını açar.
  Future<void> openAppSettings() => _locationService.openSettings();
}
