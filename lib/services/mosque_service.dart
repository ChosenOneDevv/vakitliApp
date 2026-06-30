import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:vakitli/models/mosque.dart';

/// OpenStreetMap Overpass API ile yakındaki camileri bulur (anahtarsız).
class MosqueService {
  /// Overpass instance'ları sırayla denenir (biri 406/429/504 verirse diğeri).
  static const List<String> _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Overpass/Apache, User-Agent'sız istekleri 406 ile reddeder → bu şart.
  static const Map<String, String> _headers = {
    'User-Agent': 'VakitliApp/1.0 (namaz vakitleri; cami bulucu)',
    'Accept': 'application/json',
  };

  static const Distance _distance = Distance();

  Future<List<Mosque>> findNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 3000,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
);
out center 60;
''';

    http.Response? response;
    for (final endpoint in _endpoints) {
      try {
        final res = await http
            .post(Uri.parse(endpoint),
                headers: _headers, body: {'data': query})
            .timeout(const Duration(seconds: 25));
        if (res.statusCode == 200) {
          response = res;
          break;
        }
        debugPrint('MosqueService: $endpoint HTTP ${res.statusCode}');
      } catch (e) {
        debugPrint('MosqueService: $endpoint hata: $e');
      }
    }

    if (response == null) return [];

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (json['elements'] as List?) ?? [];
      final origin = LatLng(latitude, longitude);
      final mosques = <Mosque>[];

      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>?;
        double? lat;
        double? lng;
        if (el['lat'] != null && el['lon'] != null) {
          lat = (el['lat'] as num).toDouble();
          lng = (el['lon'] as num).toDouble();
        } else if (el['center'] != null) {
          final c = el['center'] as Map<String, dynamic>;
          lat = (c['lat'] as num).toDouble();
          lng = (c['lon'] as num).toDouble();
        }
        if (lat == null || lng == null) continue;

        final name = (tags?['name'] as String?) ?? 'İsimsiz Cami';
        final dist = _distance.as(LengthUnit.Meter, origin, LatLng(lat, lng));
        mosques.add(Mosque(
          name: name,
          latitude: lat,
          longitude: lng,
          distanceMeters: dist,
        ));
      }

      mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return mosques;
    } catch (e) {
      debugPrint('MosqueService.findNearby hata: $e');
      return [];
    }
  }
}
