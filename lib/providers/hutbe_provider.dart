import 'package:flutter/material.dart';
import 'package:vakitli/models/hutbe.dart';
import 'package:vakitli/services/hutbe_service.dart';

class HutbeProvider extends ChangeNotifier {
  final HutbeService _service = HutbeService();

  Hutbe? _hutbe;
  bool _isLoading = false;
  String? _error;

  Hutbe? get hutbe => _hutbe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _hutbe = await _service.getHutbe();
      if (_hutbe == null) {
        _error = 'Hutbe yüklenemedi. İnternet bağlantınızı kontrol edin.';
      }
    } catch (e) {
      _error = 'Hutbe yüklenirken hata oluştu.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _hutbe = null;
    await load();
  }
}
