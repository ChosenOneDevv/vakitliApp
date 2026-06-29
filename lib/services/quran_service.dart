import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/quran_models.dart';

class QuranService {
  List<Surah>? _cached;

  Future<List<Surah>> loadSurahs() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/quran_uthmani.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['surahs'] as List;
    _cached = list.map((s) => Surah.fromJson(s as Map<String, dynamic>)).toList();
    return _cached!;
  }

  Future<Surah?> getSurah(int number) async {
    final surahs = await loadSurahs();
    if (number < 1 || number > surahs.length) return null;
    return surahs[number - 1];
  }
}
