/// Tek bir tesbih/zikir profili (ör. "Sübhanallah", hedef 33).
class TasbihProfile {
  final int id;
  final String name;

  /// Hedef sayı (33, 99, özel).
  final int target;

  /// Mevcut tur sayısı (reset ile sıfırlanır).
  final int count;

  /// Bu profille tüm zamanların toplam zikri (reset etkilemez).
  final int total;

  TasbihProfile({
    required this.id,
    required this.name,
    required this.target,
    this.count = 0,
    this.total = 0,
  });

  /// Hedefe ulaşıldı mı (count hedefin katı oldu mu).
  bool get targetReached => count > 0 && count % target == 0;

  /// 0.0-1.0 arası ilerleme (mevcut tur içinde).
  double get progress {
    if (target == 0) return 0;
    final inCycle = count % target;
    // Tam katlarda halka dolu görünsün.
    return inCycle == 0 && count > 0 ? 1.0 : inCycle / target;
  }

  TasbihProfile copyWith({String? name, int? target, int? count, int? total}) {
    return TasbihProfile(
      id: id,
      name: name ?? this.name,
      target: target ?? this.target,
      count: count ?? this.count,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
        'count': count,
        'total': total,
      };

  factory TasbihProfile.fromJson(Map<String, dynamic> json) {
    return TasbihProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      target: json['target'] as int,
      count: (json['count'] as int?) ?? 0,
      total: (json['total'] as int?) ?? 0,
    );
  }
}
