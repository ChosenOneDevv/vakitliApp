import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vakitli/models/dua.dart';

class DuaService {
  List<Dua>? _cached;

  Future<List<Dua>> loadDuas() async {
    if (_cached != null) return _cached!;

    final jsonString = await rootBundle.loadString('assets/data/duas.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _cached = jsonList
        .map((item) => Dua.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cached!;
  }
}
