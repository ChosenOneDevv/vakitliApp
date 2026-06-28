import 'package:flutter/material.dart';
import 'package:vakitli/models/prayer_log.dart';
import 'package:vakitli/services/tracker_service.dart';

/// Haftalık grafik için tek günün özeti.
class DaySummary {
  final DateTime date;
  final int completed;

  const DaySummary({required this.date, required this.completed});

  int get total => PrayerLog.prayerKeys.length;
}

class TrackerProvider extends ChangeNotifier {
  final TrackerService _service = TrackerService();

  Map<String, PrayerLog> _logs = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _logs = await _service.loadLogs();
    _isLoading = false;
    notifyListeners();
  }

  PrayerLog logForDay(DateTime date) {
    final key = TrackerService.dateKey(date);
    return _logs[key] ?? PrayerLog.empty(key);
  }

  PrayerLog get todayLog => logForDay(DateTime.now());

  Future<void> togglePrayer(String prayerKey) async {
    final key = TrackerService.dateKey(DateTime.now());
    final current = _logs[key] ?? PrayerLog.empty(key);
    _logs[key] = current.copyWithToggle(prayerKey);
    notifyListeners();
    await _service.saveLogs(_logs);
  }

  /// Son 7 günün özeti (en eski -> bugün).
  List<DaySummary> get weeklySummary {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
      return DaySummary(date: date, completed: logForDay(date).completedCount);
    });
  }

  /// İçinde bulunulan ayda kılınan toplam farz namaz.
  int get monthlyCompleted {
    final now = DateTime.now();
    var total = 0;
    for (final log in _logs.values) {
      final parts = log.date.split('-');
      if (parts.length != 3) continue;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == now.year && month == now.month) {
        total += log.completedCount;
      }
    }
    return total;
  }

  /// Tüm zamanların toplam kılınan farz namaz sayısı.
  int get totalCompleted =>
      _logs.values.fold(0, (sum, log) => sum + log.completedCount);

  /// Ardışık tam-gün (5 vakit) serisi. Bugün veya dün ile bitmeli, yoksa 0.
  int get streak {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Seri bugünden mi yoksa dünden mi başlıyor belirle.
    DateTime cursor;
    if (logForDay(today).isComplete) {
      cursor = today;
    } else if (logForDay(today.subtract(const Duration(days: 1))).isComplete) {
      cursor = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    var count = 0;
    while (logForDay(cursor).isComplete) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}
