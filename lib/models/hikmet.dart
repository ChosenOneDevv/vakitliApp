class Hikmet {
  final int id;
  final String text;
  final String author;
  final String topic;

  const Hikmet({
    required this.id,
    required this.text,
    required this.author,
    required this.topic,
  });

  factory Hikmet.fromJson(Map<String, dynamic> json) {
    return Hikmet(
      id: json['id'] as int,
      text: json['text'] as String,
      author: json['author'] as String,
      topic: json['topic'] as String,
    );
  }
}
