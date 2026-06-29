class Hutbe {
  final String title;
  final String date;
  final String text;
  final String source;
  final DateTime fetchedAt;

  Hutbe({
    required this.title,
    required this.date,
    required this.text,
    required this.source,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'text': text,
        'source': source,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory Hutbe.fromJson(Map<String, dynamic> json) {
    return Hutbe(
      title: json['title'] as String,
      date: json['date'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  /// Cache 7 gün geçerliliğini korur.
  bool get isStale =>
      DateTime.now().difference(fetchedAt).inDays >= 7;
}
