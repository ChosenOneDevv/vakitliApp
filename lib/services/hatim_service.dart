import 'package:shared_preferences/shared_preferences.dart';

/// Hatim (Kuran okuma) ilerlemesini SharedPreferences'da saklar.
class HatimService {
  /// Standart Mushaf sayfa sayısı (1 hatim).
  static const int totalPages = 604;

  static const String _pageKey = 'hatim_current_page';
  static const String _goalKey = 'hatim_daily_goal';
  static const String _completedKey = 'hatim_completed_count';

  Future<int> loadCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pageKey) ?? 0;
  }

  Future<void> saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageKey, page);
  }

  Future<int> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalKey) ?? 20;
  }

  Future<void> saveDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalKey, goal);
  }

  Future<int> loadCompletedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedKey) ?? 0;
  }

  Future<void> saveCompletedCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_completedKey, count);
  }
}
