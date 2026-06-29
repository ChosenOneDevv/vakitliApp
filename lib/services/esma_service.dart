import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/esma_name.dart';

class EsmaService {
  List<EsmaName>? _cached;

  Future<List<EsmaName>> load() async {
    if (_cached != null) return _cached!;
    final jsonStr = await rootBundle.loadString('assets/data/esma.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    _cached =
        list.map((e) => EsmaName.fromJson(e as Map<String, dynamic>)).toList();
    return _cached!;
  }
}
