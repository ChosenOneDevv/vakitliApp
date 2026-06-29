import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/constants.dart';
import 'package:vakitli/models/hutbe.dart';

class HutbeService {
  static const String _cacheKey = 'hutbe_cache';

  /// Önce cache kontrol eder; stale veya forceRefresh ise Diyanet'ten çeker.
  Future<Hutbe?> getHutbe({bool forceRefresh = false}) async {
    final cached = await _loadCached();
    if (!forceRefresh && cached != null && !cached.isStale) return cached;

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
      // 1. Ana sayfadan güncel hutbe detail URL'ini al
      final mainResp = await http
          .get(
            Uri.parse('https://www.diyanet.gov.tr/tr-TR/'),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(AppConstants.httpTimeout);
      if (mainResp.statusCode != 200) return null;

      final linkMatch = RegExp(
        r'href="(/tr-TR/Kurumsal/Detay/\d+/cuma-hutbesi[^"]*)"',
      ).firstMatch(mainResp.body);
      if (linkMatch == null) return null;

      final detailPath = linkMatch.group(1)!;

      // 2. Detail sayfasını çek
      final detailResp = await http
          .get(
            Uri.parse('https://www.diyanet.gov.tr$detailPath'),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(AppConstants.httpTimeout);
      if (detailResp.statusCode != 200) return null;

      final body = detailResp.body;

      // Başlık
      final titleMatch = RegExp(r'<title[^>]*>([^<]+)</title>').firstMatch(body);
      final rawTitle = titleMatch?.group(1)?.trim() ?? 'Cuma Hutbesi';
      final title = rawTitle
          .replaceAll(RegExp(r'\s*[-|]\s*Diyanet.*', caseSensitive: false), '')
          .replaceAll('&quot;', '"')
          .trim();

      // İçerik: <div class="content-detail">...</div>
      final contentMatch = RegExp(
        r'<div[^>]*class="content-detail"[^>]*>([\s\S]*?)</div>\s*</div>',
        caseSensitive: false,
      ).firstMatch(body);

      String text = '';
      if (contentMatch != null) {
        text = _stripHtml(contentMatch.group(1) ?? '');
      } else {
        // Fallback: uzun <p> taglerini topla
        text = RegExp(r'<p[^>]*>([\s\S]*?)</p>', caseSensitive: false)
            .allMatches(body)
            .map((m) => _stripHtml(m.group(1) ?? '').trim())
            .where((t) => t.length > 80)
            .take(12)
            .join('\n\n');
      }

      if (text.trim().isEmpty) return null;

      final now = DateTime.now();
      return Hutbe(
        title: title.isNotEmpty ? title : 'Cuma Hutbesi',
        date: '${now.day}.${now.month}.${now.year}',
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
    var s = html.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // Numeric entities (decimal): &#123; or &#x7B;
    s = s.replaceAllMapped(RegExp(r'&#([0-9]+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });
    s = s.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });

    // Named entities (common + Turkish-relevant)
    const entities = {
      '&nbsp;': ' ', '&amp;': '&', '&lt;': '<', '&gt;': '>',
      '&quot;': '"', '&apos;': "'",
      '&ldquo;': '"', '&rdquo;': '"', '&lsquo;': '‘', '&rsquo;': '’',
      '&mdash;': '—', '&ndash;': '–', '&hellip;': '…',
      '&copy;': '©',
      // Latin extended (Turkish)
      '&ccedil;': 'ç', '&Ccedil;': 'Ç',
      '&ouml;': 'ö', '&Ouml;': 'Ö',
      '&uuml;': 'ü', '&Uuml;': 'Ü',
      '&acirc;': 'â', '&Acirc;': 'Â',
      '&icirc;': 'î', '&Icirc;': 'Î',
      '&ucirc;': 'û', '&Ucirc;': 'Û',
      '&ecirc;': 'ê', '&Ecirc;': 'Ê',
      '&atilde;': 'ã', '&otilde;': 'õ',
    };
    for (final entry in entities.entries) {
      s = s.replaceAll(entry.key, entry.value);
    }

    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
