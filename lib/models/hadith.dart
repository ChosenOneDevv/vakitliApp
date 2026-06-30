class Hadith {
  final int id;
  final String text;
  final String source;
  final String narrator;
  final String topic;

  /// Hadis derecesi (Sahih, Hasen vb.) — API'den gelen hadisler için dolu.
  final String? grade;

  Hadith({
    required this.id,
    required this.text,
    required this.source,
    required this.narrator,
    required this.topic,
    this.grade,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as int,
      text: json['text'] as String,
      source: json['source'] as String,
      narrator: json['narrator'] as String,
      topic: json['topic'] as String,
    );
  }

  /// HadeethEnc.com API yanıtından Hadith oluşturur.
  /// API ID'leri 100001+ aralığına kaydırılır → yerel 1-40 ile çakışma önlenir.
  factory Hadith.fromApiJson(Map<String, dynamic> json) {
    final apiId = int.tryParse(json['id'].toString()) ?? 0;
    return Hadith(
      id: 100000 + apiId,
      text: (json['hadeeth'] as String? ?? '').trim(),
      source: (json['reference'] as String? ?? '').trim(),
      narrator: (json['attribution'] as String? ?? '').trim(),
      topic: (json['title'] as String? ?? '').trim(),
      grade: json['grade'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'source': source,
        'narrator': narrator,
        'topic': topic,
        if (grade != null) 'grade': grade,
      };
}
