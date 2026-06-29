import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/models/madhab.dart';

class MadhabProvider extends ChangeNotifier {
  static const String _key = 'madhab';
  static const String _legacySchoolKey = 'asr_school';

  Madhab _madhab = Madhab.hanafi;

  Madhab get madhab => _madhab;
  int get asrSchool => _madhab.asrSchool;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_key)) {
      _madhab = Madhab.fromName(prefs.getString(_key) ?? 'hanafi');
    } else {
      // Eski 'asr_school' değerinden mezhebe geç: 1=Hanefî, 0=Şâfiî varsayılan.
      final legacy = prefs.getInt(_legacySchoolKey);
      _madhab = legacy == 1 ? Madhab.hanafi : Madhab.shafii;
    }
    notifyListeners();
  }

  Future<void> setMadhab(Madhab madhab) async {
    if (_madhab == madhab) return;
    _madhab = madhab;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, madhab.name);
    notifyListeners();
  }
}
