import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { male, female }

class ProfileProvider extends ChangeNotifier {
  static const String _key = 'gender';

  Gender _gender = Gender.male;

  Gender get gender => _gender;
  bool get isFemale => _gender == Gender.female;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'female') {
      _gender = Gender.female;
    }
    notifyListeners();
  }

  Future<void> setGender(Gender gender) async {
    if (_gender == gender) return;
    _gender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, gender == Gender.female ? 'female' : 'male');
    notifyListeners();
  }
}
