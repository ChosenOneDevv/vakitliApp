import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/sunnah_lesson.dart';

class FemaleContentService {
  List<SunnahLesson>? _cache;

  Future<List<SunnahLesson>> loadAll() async {
    if (_cache != null) return _cache!;
    final json =
        await rootBundle.loadString('assets/data/female_content.json');
    final list = jsonDecode(json) as List<dynamic>;
    _cache = list
        .map((e) => SunnahLesson.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<String>> loadCategories() async {
    final items = await loadAll();
    final seen = <String>{};
    return items.map((i) => i.category).where(seen.add).toList();
  }

  Future<List<SunnahLesson>> loadByCategory(String category) async {
    final items = await loadAll();
    return items.where((i) => i.category == category).toList();
  }
}
