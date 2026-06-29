import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/sunnah_lesson.dart';

class SunnahService {
  List<SunnahLesson>? _cache;

  Future<List<SunnahLesson>> loadAll() async {
    if (_cache != null) return _cache!;
    final json = await rootBundle.loadString('assets/data/sunnah_lessons.json');
    final list = jsonDecode(json) as List<dynamic>;
    _cache = list
        .map((e) => SunnahLesson.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<String>> loadCategories() async {
    final lessons = await loadAll();
    final seen = <String>{};
    return lessons
        .map((l) => l.category)
        .where(seen.add)
        .toList();
  }

  Future<List<SunnahLesson>> loadByCategory(String category) async {
    final lessons = await loadAll();
    return lessons.where((l) => l.category == category).toList();
  }
}
