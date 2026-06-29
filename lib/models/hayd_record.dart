class HaydRecord {
  final String id;
  final DateTime startDate;
  final DateTime endDate;

  const HaydRecord({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  factory HaydRecord.fromJson(Map<String, dynamic> json) => HaydRecord(
        id: json['id'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}
