import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/tebrik_card.dart';

class TebrikProvider extends ChangeNotifier {
  static const _cacheKey = 'tebrik_cache';
  static const _collection = 'tebrik_kartlari';

  List<TebrikCard> _cards = TebrikCard.defaults;
  bool _isLoading = false;
  String? _error;

  List<TebrikCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TebrikProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadCache();
    await _fetchFromFirestore();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        final cards = list.map(TebrikCard.fromJson).toList();
        if (cards.isNotEmpty) {
          _cards = cards;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snap.docs.isNotEmpty) {
        final cards = snap.docs
            .map((d) => TebrikCard.fromFirestoreJson(d.id, d.data()))
            .where((c) => c.title.isNotEmpty)
            .toList();

        _cards = cards;
        _error = null;
        await _saveCache(cards);
        notifyListeners();
      }
    } catch (e) {
      // Keep cached/default cards on error — no error shown if we have cards
      if (_cards.isEmpty) {
        _error = 'Kartlar yüklenirken hata oluştu.';
        _cards = TebrikCard.defaults;
        notifyListeners();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _fetchFromFirestore();

  Future<void> _saveCache(List<TebrikCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(cards.map((c) => c.toJson()).toList()),
      );
    } catch (_) {}
  }
}
