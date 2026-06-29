class EsmaName {
  final int id;
  final String arabic;
  final String transliteration;
  final String meaning;

  EsmaName({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  factory EsmaName.fromJson(Map<String, dynamic> json) {
    return EsmaName(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
    );
  }
}
