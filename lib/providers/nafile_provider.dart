import 'package:flutter/material.dart';
import 'package:vakitli/services/nafile_service.dart';

class NafileProvider extends ChangeNotifier {
  final NafileService _service = NafileService();

  Map<String, Map<String, bool>> _logs = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _logs = await _service.load();
    _isLoading = false;
    notifyListeners();
  }

  bool isDoneToday(String key) {
    final today = NafileService.dateKey(DateTime.now());
    return _logs[today]?[key] ?? false;
  }

  /// Bir nafile türünün tüm zamanlardaki toplam sayısı.
  int totalFor(String key) =>
      _logs.values.where((day) => day[key] == true).length;

  /// Bugün kılınan nafile sayısı.
  int get todayCount {
    final today = NafileService.dateKey(DateTime.now());
    final day = _logs[today];
    if (day == null) return 0;
    return NafileService.keys.where((k) => day[k] == true).length;
  }

  Future<void> toggleToday(String key) async {
    final today = NafileService.dateKey(DateTime.now());
    final day = Map<String, bool>.from(_logs[today] ?? {});
    day[key] = !(day[key] ?? false);
    _logs[today] = day;
    notifyListeners();
    await _service.save(_logs);
  }
}
