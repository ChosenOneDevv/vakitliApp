import 'dart:convert';

enum AmelCategory { namaz, sadaka, zikir, kuran, diger }

extension AmelCategoryExt on AmelCategory {
  String get label {
    switch (this) {
      case AmelCategory.namaz:
        return 'Namaz';
      case AmelCategory.sadaka:
        return 'Sadaka';
      case AmelCategory.zikir:
        return 'Zikir';
      case AmelCategory.kuran:
        return 'Kuran';
      case AmelCategory.diger:
        return 'Diğer';
    }
  }
}

class AmelEntry {
  final String id;
  final String date;
  final String text;
  final AmelCategory category;
  final int count;

  AmelEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.category,
    this.count = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'text': text,
        'category': category.index,
        'count': count,
      };

  factory AmelEntry.fromJson(Map<String, dynamic> json) {
    return AmelEntry(
      id: json['id'] as String,
      date: json['date'] as String,
      text: json['text'] as String,
      category: AmelCategory.values[json['category'] as int? ?? 4],
      count: json['count'] as int? ?? 1,
    );
  }

  static List<AmelEntry> listFromJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => AmelEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<AmelEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }
}
