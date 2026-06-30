/// Camiye girince/çıkınca yapılan sessize alma işleminin kaydı (Faz 25 log).
class DndLogEntry {
  final String mosqueName;

  /// true → girince sessize alındı, false → çıkınca ses açıldı.
  final bool silenced;
  final DateTime time;

  DndLogEntry({
    required this.mosqueName,
    required this.silenced,
    required this.time,
  });

  factory DndLogEntry.fromJson(Map<String, dynamic> json) => DndLogEntry(
        mosqueName: json['mosqueName'] as String,
        silenced: json['silenced'] as bool,
        time: DateTime.parse(json['time'] as String),
      );

  Map<String, dynamic> toJson() => {
        'mosqueName': mosqueName,
        'silenced': silenced,
        'time': time.toIso8601String(),
      };
}
