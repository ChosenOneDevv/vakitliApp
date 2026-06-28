import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });
}

class LocationService {
  static const String _keyLat = 'location_latitude';
  static const String _keyLng = 'location_longitude';
  static const String _keyCity = 'location_city';

  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String cityName = 'Bilinmeyen Konum';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          cityName = place.administrativeArea ?? place.locality ?? place.subAdministrativeArea ?? 'Bilinmeyen Konum';
        }
      } catch (e) {
        debugPrint('LocationService geocoding hata: $e');
      }

      final data = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );

      await saveLocation(data);
      return data;
    } catch (e) {
      debugPrint('LocationService getCurrentLocation hata: $e');
      return null;
    }
  }

  /// Konum izni kalıcı reddedilmiş mi (kullanıcı Ayarlar'a yönlendirilmeli).
  Future<bool> isPermanentlyDenied() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Cihaz uygulama ayarlarını açar (kalıcı red sonrası izin için).
  Future<bool> openSettings() => Geolocator.openAppSettings();

  Future<void> saveLocation(LocationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLat, data.latitude);
    await prefs.setDouble(_keyLng, data.longitude);
    await prefs.setString(_keyCity, data.cityName);
  }

  Future<LocationData?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_keyLat);
    final lng = prefs.getDouble(_keyLng);
    final city = prefs.getString(_keyCity);

    if (lat != null && lng != null && city != null) {
      return LocationData(latitude: lat, longitude: lng, cityName: city);
    }
    return null;
  }

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
