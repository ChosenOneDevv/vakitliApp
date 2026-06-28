import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vakitli/services/qibla_service.dart';

class QiblaProvider extends ChangeNotifier {
  double? _compassHeading;
  double _qiblaDirection = 0;
  double _distanceToKaaba = 0;
  bool _hasCompass = false;
  bool _initialized = false;
  String? _error;
  StreamSubscription<CompassEvent>? _compassSubscription;

  double? get compassHeading => _compassHeading;
  double get qiblaDirection => _qiblaDirection;
  double get distanceToKaaba => _distanceToKaaba;
  bool get hasCompass => _hasCompass;
  bool get initialized => _initialized;
  String? get error => _error;

  /// Kıble açısı: pusula heading'i ile qibla direction arasındaki fark
  double get qiblaAngle {
    if (_compassHeading == null) return _qiblaDirection;
    return _qiblaDirection - _compassHeading!;
  }

  Future<void> initialize(double latitude, double longitude) async {
    _qiblaDirection = QiblaService.calculateQiblaDirection(latitude, longitude);
    _distanceToKaaba = QiblaService.calculateDistanceToKaaba(latitude, longitude);

    try {
      _hasCompass = FlutterCompass.events != null;
      if (_hasCompass) {
        _startCompass();
        _error = null;
      } else {
        _error = 'Bu cihazda pusula sensörü bulunamadı.';
      }
    } catch (e) {
      _hasCompass = false;
      _error = 'Pusula sensörüne erişilemedi.';
    }

    _initialized = true;
    notifyListeners();
  }

  void _startCompass() {
    _compassSubscription?.cancel();
    try {
      _compassSubscription = FlutterCompass.events?.listen(
        (event) {
          _compassHeading = event.heading;
          notifyListeners();
        },
        onError: (_) {
          _hasCompass = false;
          _error = 'Pusula verisi okunamadı.';
          notifyListeners();
        },
      );
    } catch (e) {
      _hasCompass = false;
      _error = 'Pusula başlatılamadı.';
    }
  }

  /// Sensör mevcut mu kontrolü (statik, MainShell'den çağrılır)
  static Future<bool> checkCompassAvailability() async {
    try {
      return FlutterCompass.events != null;
    } catch (_) {
      return false;
    }
  }

  void updateLocation(double latitude, double longitude) {
    _qiblaDirection = QiblaService.calculateQiblaDirection(latitude, longitude);
    _distanceToKaaba = QiblaService.calculateDistanceToKaaba(latitude, longitude);
    notifyListeners();
  }

  String get formattedDistance {
    if (_distanceToKaaba > 1000) {
      return '${(_distanceToKaaba / 1000).toStringAsFixed(0)} bin km';
    }
    return '${_distanceToKaaba.toStringAsFixed(0)} km';
  }

  String get formattedQiblaDirection {
    return '${_qiblaDirection.toStringAsFixed(1)}°';
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}
