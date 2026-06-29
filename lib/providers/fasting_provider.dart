import 'package:flutter/material.dart';
import 'package:vakitli/services/fasting_service.dart';

class FastingProvider extends ChangeNotifier {
  final FastingService _service = FastingService();

  Set<String> _days = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int get totalDays => _days.length;

  bool get isFastedToday => _days.contains(FastingService.dateKey(DateTime.now()));

  /// İçinde bulunulan aydaki tutulan oruç sayısı.
  int get thisMonthCount {
    final now = DateTime.now();
    final prefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-';
    return _days.where((d) => d.startsWith(prefix)).length;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _days = await _service.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleToday() async {
    final key = FastingService.dateKey(DateTime.now());
    if (_days.contains(key)) {
      _days.remove(key);
    } else {
      _days.add(key);
    }
    notifyListeners();
    await _service.save(_days);
  }
}
