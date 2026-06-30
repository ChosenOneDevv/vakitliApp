import 'package:flutter/material.dart';
import 'package:vakitli/services/hatim_service.dart';

class HatimProvider extends ChangeNotifier {
  final HatimService _service = HatimService();

  int _currentPage = 0;
  int _dailyGoal = 20;
  int _completedCount = 0;
  bool _isLoading = false;

  int get currentPage => _currentPage;
  int get dailyGoal => _dailyGoal;
  int get completedCount => _completedCount;
  bool get isLoading => _isLoading;

  int get totalPages => HatimService.totalPages;
  int get remainingPages => HatimService.totalPages - _currentPage;

  /// 0.0 - 1.0 arası mevcut hatim ilerlemesi.
  double get progress =>
      HatimService.totalPages == 0 ? 0 : _currentPage / HatimService.totalPages;

  /// Günlük hedefe göre kalan gün sayısı (yukarı yuvarlanır).
  int get estimatedDays =>
      _dailyGoal <= 0 ? 0 : (remainingPages / _dailyGoal).ceil();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _currentPage = await _service.loadCurrentPage();
    _dailyGoal = await _service.loadDailyGoal();
    _completedCount = await _service.loadCompletedCount();
    _isLoading = false;
    notifyListeners();
  }

  /// Okunan sayfa ekler. Hatim tamamlanırsa sayaç artar, sayfa sıfırlanır.
  Future<void> addPages(int count) async {
    if (count == 0) return;
    var page = _currentPage + count;
    if (page < 0) page = 0;
    while (page >= HatimService.totalPages) {
      page -= HatimService.totalPages;
      _completedCount++;
    }
    _currentPage = page;
    notifyListeners();
    await _service.saveCurrentPage(_currentPage);
    await _service.saveCompletedCount(_completedCount);
  }

  /// Mevcut sayfayı doğrudan ayarlar (0 - totalPages aralığı).
  Future<void> setCurrentPage(int page) async {
    _currentPage = page.clamp(0, HatimService.totalPages);
    notifyListeners();
    await _service.saveCurrentPage(_currentPage);
  }

  Future<void> setDailyGoal(int goal) async {
    if (goal < 1) return;
    _dailyGoal = goal;
    notifyListeners();
    await _service.saveDailyGoal(_dailyGoal);
  }

  /// Mevcut hatmi sıfırlar (tamamlanan sayaç korunur).
  Future<void> resetProgress() async {
    _currentPage = 0;
    notifyListeners();
    await _service.saveCurrentPage(_currentPage);
  }
}
