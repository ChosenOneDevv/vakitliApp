import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vakitli/models/tasbih_profile.dart';
import 'package:vakitli/services/tasbih_service.dart';

class TasbihProvider extends ChangeNotifier {
  final TasbihService _service = TasbihService();

  List<TasbihProfile> _profiles = [];
  int _activeId = 0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<TasbihProfile> get profiles => List.unmodifiable(_profiles);

  TasbihProfile? get active {
    if (_profiles.isEmpty) return null;
    return _profiles.firstWhere(
      (p) => p.id == _activeId,
      orElse: () => _profiles.first,
    );
  }

  /// Tüm profillerin toplam zikri.
  int get grandTotal => _profiles.fold(0, (sum, p) => sum + p.total);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _profiles = await _service.loadProfiles();
    _activeId = await _service.loadActiveId() ?? _profiles.first.id;
    _isLoading = false;
    notifyListeners();
  }

  void selectProfile(int id) {
    _activeId = id;
    notifyListeners();
    _service.saveActiveId(id);
  }

  Future<void> increment() async {
    final current = active;
    if (current == null) return;

    final updated = current.copyWith(
      count: current.count + 1,
      total: current.total + 1,
    );
    _replace(updated);

    // Hedef katına ulaşınca güçlü, normalde hafif titreşim.
    if (updated.targetReached) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    notifyListeners();
    await _service.saveProfiles(_profiles);
  }

  Future<void> resetCurrent() async {
    final current = active;
    if (current == null) return;
    _replace(current.copyWith(count: 0));
    notifyListeners();
    await _service.saveProfiles(_profiles);
  }

  Future<void> setTarget(int target) async {
    final current = active;
    if (current == null || target < 1) return;
    _replace(current.copyWith(target: target));
    notifyListeners();
    await _service.saveProfiles(_profiles);
  }

  Future<void> addProfile(String name, int target) async {
    final nextId = _profiles.isEmpty
        ? 1
        : _profiles.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    _profiles.add(TasbihProfile(id: nextId, name: name, target: target));
    _activeId = nextId;
    notifyListeners();
    await _service.saveProfiles(_profiles);
    await _service.saveActiveId(nextId);
  }

  Future<void> deleteProfile(int id) async {
    if (_profiles.length <= 1) return; // son profili silme
    _profiles.removeWhere((p) => p.id == id);
    if (_activeId == id) {
      _activeId = _profiles.first.id;
      await _service.saveActiveId(_activeId);
    }
    notifyListeners();
    await _service.saveProfiles(_profiles);
  }

  void _replace(TasbihProfile updated) {
    final index = _profiles.indexWhere((p) => p.id == updated.id);
    if (index != -1) _profiles[index] = updated;
  }
}
