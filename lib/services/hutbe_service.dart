import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/constants.dart';
import 'package:vakitli/models/hutbe.dart';

class HutbeService {
  static const String _cacheKey = 'hutbe_cache';

  /// Önce cache kontrol eder; stale ise Diyanet'ten çeker.
  Future<Hutbe?> getHutbe() async {
    final cached = await _loadCached();
    if (cached != null && !cached.isStale) return cached;

    final fetched = await _fetchFromDiyanet();
    if (fetched != null) {
      await _saveCache(fetched);
      return fetched;
    }
    return cached; // offline fallback
  }

  Future<Hutbe?> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cacheKey);
    if (jsonStr == null) return null;
    try {
      return Hutbe.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(Hutbe hutbe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(hutbe.toJson()));
  }

  Future<Hutbe?> _fetchFromDiyanet() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://hutbeler.diyanet.gov.tr/'),
            headers: {'User-Agent': 'Mozilla/5.0', 'Accept-Charset': 'UTF-8'},
          )
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode != 200) return null;

      final body = response.body;

      // Başlık: <h1> veya meta title içinden
      final titleMatch =
          RegExp(r'<title[^>]*>([^<]+)</title>').firstMatch(body);
      final rawTitle = titleMatch?.group(1)?.trim() ?? 'Cuma Hutbesi';
      final title = rawTitle
          .replaceAll(RegExp(r'\s*[-|]\s*Diyanet.*', caseSensitive: false), '')
          .trim();

      // Hutbe metni: <div class="hutbe-detay-icerik"> veya <article> içinden
      String text = '';
      final contentMatch = RegExp(
        r'<div[^>]*class="[^"]*hutbe[^"]*icerik[^"]*"[^>]*>([\s\S]*?)</div>',
        caseSensitive: false,
      ).firstMatch(body);
      if (contentMatch != null) {
        text = _stripHtml(contentMatch.group(1) ?? '');
      } else {
        // Fallback: tüm <p> taglerinden metin topla
        final pTags = RegExp(r'<p[^>]*>([\s\S]*?)</p>', caseSensitive: false)
            .allMatches(body)
            .map((m) => _stripHtml(m.group(1) ?? '').trim())
            .where((t) => t.length > 100)
            .take(10)
            .join('\n\n');
        text = pTags;
      }

      if (text.trim().isEmpty) return null;

      final now = DateTime.now();
      return Hutbe(
        title: title.isNotEmpty ? title : 'Cuma Hutbesi',
        date:
            '${now.day}.${now.month}.${now.year}',
        text: text.trim(),
        source: 'Diyanet İşleri Başkanlığı',
        fetchedAt: now,
      );
    } catch (e) {
      debugPrint('HutbeService fetch hata: $e');
      return null;
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
