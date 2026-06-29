import 'package:flutter/material.dart';
import 'package:vakitli/models/hayd_record.dart';
import 'package:vakitli/services/hayd_service.dart';

class HaydProvider extends ChangeNotifier {
  final HaydService _service = HaydService();

  List<HaydRecord> _records = [];
  bool _isLoading = false;

  List<HaydRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;

  /// Kaydedilen tüm hayız kayıtlarının toplam gün sayısı.
  int get totalHaydDays =>
      _records.fold(0, (sum, r) => sum + r.durationDays);

  /// İki tarih arasındaki hayız günü sayısı (kaza hesabı için).
  int haydDaysBetween(DateTime start, DateTime end) {
    int count = 0;
    for (final record in _records) {
      final overlapStart =
          record.startDate.isAfter(start) ? record.startDate : start;
      final overlapEnd =
          record.endDate.isBefore(end) ? record.endDate : end;
      if (!overlapStart.isAfter(overlapEnd)) {
        count += overlapEnd.difference(overlapStart).inDays + 1;
      }
    }
    return count;
  }

  /// Verilen tarih hayız döneminde mi?
  bool isHaydOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _records.any(
      (r) =>
          !d.isBefore(DateTime(r.startDate.year, r.startDate.month, r.startDate.day)) &&
          !d.isAfter(DateTime(r.endDate.year, r.endDate.month, r.endDate.day)),
    );
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _records = await _service.load();
    _records.sort((a, b) => b.startDate.compareTo(a.startDate));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(DateTime start, DateTime end) async {
    final record = HaydRecord(
      id: '${start.millisecondsSinceEpoch}',
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(end.year, end.month, end.day),
    );
    _records.insert(0, record);
    notifyListeners();
    await _service.save(_records);
  }

  Future<void> removeRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
    await _service.save(_records);
  }
}
