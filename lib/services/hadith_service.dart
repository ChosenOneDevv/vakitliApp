import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/hadith.dart';

class HadithService {
  List<Hadith>? _cachedHadiths;

  Future<List<Hadith>> loadHadiths() async {
    if (_cachedHadiths != null) return _cachedHadiths!;

    final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _cachedHadiths = jsonList
        .map((item) => Hadith.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cachedHadiths!;
  }

  Future<Hadith?> getDailyHadith() async {
    final hadiths = await loadHadiths();
    if (hadiths.isEmpty) return null;

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % hadiths.length;
    return hadiths[index];
  }

  Future<Hadith?> getHadithById(int id) async {
    final hadiths = await loadHadiths();
    try {
      return hadiths.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}
