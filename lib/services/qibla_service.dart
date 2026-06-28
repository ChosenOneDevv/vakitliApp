import 'dart:math';

class QiblaService {
  // Kabe koordinatları
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  /// Kullanıcının konumuna göre Kıble açısını hesaplar (derece cinsinden).
  /// Great Circle yöntemi kullanır.
  /// Dönen değer: 0-360 arası derece (kuzeye göre saat yönünde)
  static double calculateQiblaDirection(double latitude, double longitude) {
    final lat1 = _toRadians(latitude);
    final lng1 = _toRadians(longitude);
    final lat2 = _toRadians(_kaabaLatitude);
    final lng2 = _toRadians(_kaabaLongitude);

    final dLng = lng2 - lng1;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    var bearing = atan2(y, x);
    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Kullanıcının konumundan Kabe'ye olan mesafeyi km cinsinden hesaplar.
  /// Haversine formülü kullanır.
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    const earthRadius = 6371.0; // km

    final lat1 = _toRadians(latitude);
    final lng1 = _toRadians(longitude);
    final lat2 = _toRadians(_kaabaLatitude);
    final lng2 = _toRadians(_kaabaLongitude);

    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
