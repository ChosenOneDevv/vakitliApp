/// Günlük akıntı tipi (Faz 24b — kanama/lekelenme takibi).
///
/// - [bleeding]: belirgin kanama.
/// - [spotting]: lekelenme (sufra = sarımtırak, kudra = bulanık).
/// - [clean]: temizlik (akıntı yok).
enum FlowType { bleeding, spotting, clean }

extension FlowTypeTr on FlowType {
  String get displayName {
    switch (this) {
      case FlowType.bleeding:
        return 'Kanama';
      case FlowType.spotting:
        return 'Lekelenme';
      case FlowType.clean:
        return 'Temiz';
    }
  }

  /// Fıkhen kanama sayılır mı? (kanama + lekelenme = kanama hükmü).
  bool get isBloody => this != FlowType.clean;
}

/// Tek bir güne ait akıntı kaydı.
class FlowEntry {
  final DateTime date;
  final FlowType type;

  FlowEntry({required DateTime date, required this.type})
      : date = DateTime(date.year, date.month, date.day);

  factory FlowEntry.fromJson(Map<String, dynamic> json) => FlowEntry(
        date: DateTime.parse(json['date'] as String),
        type: FlowType.values[json['type'] as int],
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type.index,
      };

  /// Gün anahtarı (yyyy-MM-dd) — Map saklama için.
  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
