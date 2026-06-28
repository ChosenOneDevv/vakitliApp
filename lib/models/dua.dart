class Dua {
  final int id;
  final String category;
  final String title;
  final String arabic;

  /// Türkçe okunuş.
  final String transliteration;

  /// Türkçe anlam.
  final String meaning;

  Dua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
    );
  }
}
