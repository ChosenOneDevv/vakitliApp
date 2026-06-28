class Hadith {
  final int id;
  final String text;
  final String source;
  final String narrator;
  final String topic;

  Hadith({
    required this.id,
    required this.text,
    required this.source,
    required this.narrator,
    required this.topic,
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
}
