import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/hikmet.dart';

class HikmetService {
  List<Hikmet>? _cached;

  Future<List<Hikmet>> loadHikmetler() async {
    if (_cached != null) return _cached!;

    final jsonString =
        await rootBundle.loadString('assets/data/hikmetler.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _cached = jsonList
        .map((item) => Hikmet.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cached!;
  }

  Future<Hikmet?> getDailyHikmet() async {
    final list = await loadHikmetler();
    if (list.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return list[dayOfYear % list.length];
  }
}
