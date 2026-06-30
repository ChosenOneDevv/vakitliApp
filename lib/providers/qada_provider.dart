import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/prayer_log.dart';
import 'package:vakitli/services/qada_service.dart';
import 'package:vakitli/services/tracker_service.dart';
import 'package:vakitli/utils/qada_calculator.dart';

class QadaProvider extends ChangeNotifier {
  final QadaService _service = QadaService();
  final TrackerService _tracker = TrackerService();

  static const String _lastSyncKey = 'qada_last_auto_sync';
  // Aşırı birikmeyi önlemek için geçmişe dönük en fazla taranan gün.
  static const int _maxBackfillDays = 60;

  Map<String, int> _counts = {for (final k in QadaService.prayerKeys) k: 0};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int count(String key) => _counts[key] ?? 0;
  int get total => _counts.values.fold(0, (sum, c) => sum + c);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _counts = await _service.load();
    await _autoSyncMissed();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> increment(String key) async {
    _counts[key] = (_counts[key] ?? 0) + 1;
    notifyListeners();
    await _service.save(_counts);
  }

  /// Bir kaza namazını "kıldım" olarak işaretler (borçtan düşer).
  Future<void> decrement(String key) async {
    final current = _counts[key] ?? 0;
    if (current <= 0) return;
    _counts[key] = current - 1;
    notifyListeners();
    await _service.save(_counts);
  }

  /// Bir vaktin kaza borcunu doğrudan belirler (düzenleme).
  Future<void> setCount(String key, int value) async {
    _counts[key] = value < 0 ? 0 : value;
    notifyListeners();
    await _service.save(_counts);
  }

  /// Geçmiş günlerde takipte kılınmamış farz namazları otomatik kaza
  /// borcuna ekler (gün geçince bir sonraki açılışta yakalanır).
  /// İlk çalıştırmada geçmişe dönük ekleme yapılmaz; sadece bugünden
  /// itibaren takip edilir. Vitir takip edilmediği için dahil değildir.
  Future<void> _autoSyncMissed() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final yesterday =
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

    final lastStr = prefs.getString(_lastSyncKey);
    if (lastStr == null) {
      // İlk kez: bugünü işaretle, geçmişi sayma.
      await prefs.setString(_lastSyncKey, TrackerService.dateKey(now));
      return;
    }

    DateTime cursor;
    try {
      cursor = DateTime.parse(lastStr).add(const Duration(days: 1));
    } catch (_) {
      await prefs.setString(_lastSyncKey, TrackerService.dateKey(now));
      return;
    }

    // En fazla son [_maxBackfillDays] güne kadar tara.
    final earliest = yesterday.subtract(Duration(days: _maxBackfillDays - 1));
    if (cursor.isBefore(earliest)) cursor = earliest;

    if (cursor.isAfter(yesterday)) return; // taranacak tam gün yok

    final logs = await _tracker.loadLogs();
    var changed = false;
    while (!cursor.isAfter(yesterday)) {
      final log = logs[TrackerService.dateKey(cursor)];
      for (final key in PrayerLog.prayerKeys) {
        final done = log?.isDone(key) ?? false;
        if (!done) {
          _counts[key] = (_counts[key] ?? 0) + 1;
          changed = true;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    await prefs.setString(_lastSyncKey, TrackerService.dateKey(yesterday));
    if (changed) await _service.save(_counts);
  }

  /// [days] gün için her vakte (5 farz + Vitir) kaza ekler.
  /// İstihaze günleri kazaya sayılır (Faz 24e).
  Future<void> addDays(int days) async {
    if (days <= 0) return;
    for (final k in QadaService.prayerKeys) {
      _counts[k] = (_counts[k] ?? 0) + days;
    }
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
