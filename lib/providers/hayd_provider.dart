import 'package:flutter/material.dart';
import 'package:vakitli/models/flow_entry.dart';
import 'package:vakitli/models/hayd_record.dart';
import 'package:vakitli/models/madhhab.dart';
import 'package:vakitli/services/fiqh_engine.dart';
import 'package:vakitli/services/hayd_service.dart';

class HaydProvider extends ChangeNotifier {
  final HaydService _service = HaydService();

  List<HaydRecord> _records = [];
  List<FlowEntry> _flow = [];
  Madhhab _madhhab = Madhhab.hanefi;
  int? _habitualDays;
  bool _isLoading = false;

  List<HaydRecord> get records => List.unmodifiable(_records);
  List<FlowEntry> get flow => List.unmodifiable(_flow);
  Madhhab get madhhab => _madhhab;
  int? get habitualDays => _habitualDays;
  bool get isLoading => _isLoading;

  FiqhEngine get _engine => FiqhEngine.forMadhhab(_madhhab);

  /// Akıntı kayıtlarının fıkhi tespiti (gün → hüküm).
  List<FiqhDay> get fiqhDays =>
      _engine.classify(_flow, habitualHaydDays: _habitualDays);

  /// Bugünün fıkhi durumu (kayıt yoksa null).
  FiqhStatus? get currentStatus {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    for (final fd in fiqhDays) {
      if (fd.date == d) return fd.status;
    }
    return null;
  }

  /// Bugün muafiyet (hayız/nifas) var mı? → namaz/oruç muaf.
  bool get isExemptToday =>
      currentStatus == FiqhStatus.hayd || currentStatus == FiqhStatus.nifas;

  /// Dün hayız/nifas, bugün temiz/kayıtsız → hayız bitmiş (gusül uyarısı).
  bool get justEndedHayd {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    FiqhStatus? yStatus;
    for (final fd in fiqhDays) {
      if (fd.date == yesterday) yStatus = fd.status;
    }
    final wasExempt =
        yStatus == FiqhStatus.hayd || yStatus == FiqhStatus.nifas;
    return wasExempt && !isExemptToday;
  }

  /// Kayıtlardaki toplam istihaze günü sayısı (kazaya sayılır).
  int istihazeDaysCount() =>
      fiqhDays.where((d) => d.status == FiqhStatus.istihaze).length;

  /// Bugünkü akıntı tipi (kayıt yoksa null).
  FlowType? get todayFlow => flowOn(DateTime.now());

  FlowType? flowOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (final e in _flow) {
      if (e.date == d) return e.type;
    }
    return null;
  }

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
    _flow = await _service.loadFlow();
    _madhhab = Madhhab.values[await _service.loadMadhhabIndex()];
    _habitualDays = await _service.loadHabitualDays();
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

  // --- Fıkhi motor entegrasyonu (Faz 24) ---

  Future<void> setMadhhab(Madhhab madhhab) async {
    _madhhab = madhhab;
    notifyListeners();
    await _service.saveMadhhabIndex(madhhab.index);
  }

  Future<void> setHabitualDays(int? days) async {
    _habitualDays = (days == null || days <= 0) ? null : days;
    notifyListeners();
    await _service.saveHabitualDays(_habitualDays);
  }

  /// Bir güne akıntı tipi işaretler; aynı gün varsa günceller. [FlowType.clean]
  /// kaydı da saklanır (temiz gün fıkhi tuhr hesabı için gerekli).
  Future<void> setFlow(DateTime date, FlowType type) async {
    final d = DateTime(date.year, date.month, date.day);
    _flow.removeWhere((e) => e.date == d);
    _flow.add(FlowEntry(date: d, type: type));
    _flow.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
    await _service.saveFlow(_flow);
  }

  Future<void> clearFlow(DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    _flow.removeWhere((e) => e.date == d);
    notifyListeners();
    await _service.saveFlow(_flow);
  }
}
