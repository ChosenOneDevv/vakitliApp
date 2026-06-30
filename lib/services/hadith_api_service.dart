import 'dart:convert';
import 'package:http/http.dart' as http;

class HadithCategory {
  final String id;
  final String title;
  final int hadithCount;

  const HadithCategory({
    required this.id,
    required this.title,
    required this.hadithCount,
  });

  factory HadithCategory.fromJson(Map<String, dynamic> json) {
    return HadithCategory(
      id: json['id'].toString(),
      title: (json['title'] as String? ?? '').trim(),
      hadithCount: int.tryParse(json['hadeeths_count'].toString()) ?? 0,
    );
  }
}

class HadithApiPage {
  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;

  const HadithApiPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });
}

class HadithApiService {
  static const _base = 'https://hadeethenc.com/api/v1';
  static const _lang = 'tr';
  static const _timeout = Duration(seconds: 15);

  Future<List<HadithCategory>> fetchCategories() async {
    try {
      final uri = Uri.parse('$_base/categories/roots/?language=$_lang');
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      if (data is! List) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(HadithCategory.fromJson)
          .where((c) => c.title.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<HadithApiPage> fetchHadiths({
    required String categoryId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '$_base/hadeeths/list/?language=$_lang'
        '&category_id=$categoryId&page=$page&per_page=$perPage',
      );
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        return HadithApiPage(items: [], currentPage: page, lastPage: page);
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final meta = body['meta'] as Map<String, dynamic>? ?? {};
      final lastPage = int.tryParse(meta['last_page'].toString()) ?? 1;
      return HadithApiPage(items: data, currentPage: page, lastPage: lastPage);
    } catch (_) {
      return HadithApiPage(items: [], currentPage: page, lastPage: page);
    }
  }
}
