import 'package:flutter/material.dart';
import 'package:vakitli/services/qada_service.dart';
import 'package:vakitli/utils/qada_calculator.dart';

class QadaProvider extends ChangeNotifier {
  final QadaService _service = QadaService();

  Map<String, int> _counts = {for (final k in QadaService.prayerKeys) k: 0};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int count(String key) => _counts[key] ?? 0;
  int get total => _counts.values.fold(0, (sum, c) => sum + c);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _counts = await _service.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> increment(String key) async {
    _counts[key] = (_counts[key] ?? 0) + 1;
    notifyListeners();
    await _service.save(_counts);
  }

  Future<void> decrement(String key) async {
    final current = _counts[key] ?? 0;
    if (current <= 0) return;
    _counts[key] = current - 1;
    notifyListeners();
    await _service.save(_counts);
  }

  Future<void> addCalculated(QadaCalculation calc) async {
    _counts['fajr'] = (_counts['fajr'] ?? 0) + calc.fajr;
    _counts['dhuhr'] = (_counts['dhuhr'] ?? 0) + calc.dhuhr;
    _counts['asr'] = (_counts['asr'] ?? 0) + calc.asr;
    _counts['maghrib'] = (_counts['maghrib'] ?? 0) + calc.maghrib;
    _counts['isha'] = (_counts['isha'] ?? 0) + calc.isha;
    _counts['witr'] = (_counts['witr'] ?? 0) + calc.witr;
    notifyListeners();
    await _service.save(_counts);
  }
}
