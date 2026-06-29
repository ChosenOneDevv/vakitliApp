class SunnahLesson {
  final int id;
  final String category;
  final String title;
  final String content;
  final String? source;

  const SunnahLesson({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    this.source,
  });

  factory SunnahLesson.fromJson(Map<String, dynamic> json) => SunnahLesson(
        id: json['id'] as int,
        category: json['category'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        source: json['source'] as String?,
      );
}
