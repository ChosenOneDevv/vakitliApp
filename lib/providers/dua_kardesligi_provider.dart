import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakitli/models/dua_kardesligi.dart';
import 'package:vakitli/services/dua_kardesligi_service.dart';

class DuaKardesligiProvider extends ChangeNotifier {
  final DuaKardesligiService _service = DuaKardesligiService();

  List<DuaKardesligi> _all = [];
  List<DuaKardesligi> _mine = [];
  bool _isLoading = false;
  String? _error;
  bool _showMine = false;

  List<DuaKardesligi> get items => _showMine ? _mine : _all;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showMine => _showMine;
  bool get isSignedIn => FirebaseAuth.instance.currentUser != null;

  void toggleShowMine(bool v) {
    _showMine = v;
    notifyListeners();
  }

  void listenAll() {
    _service.streamAll().listen(
      (list) {
        _all = list;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Dua istekleri yüklenemedi.';
        notifyListeners();
      },
    );
  }

  void listenMine() {
    _service.streamMine().listen(
      (list) {
        _mine = list;
        notifyListeners();
      },
    );
  }

  Future<bool> addDua({
    required String duaText,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    final id = await _service.addDua(
      duaText: duaText,
      userName: user?.displayName ?? user?.email ?? 'Kullanıcı',
      isAnonymous: isAnonymous,
    );
    _isLoading = false;
    notifyListeners();
    return id != null;
  }

  Future<void> markPrayed(String duaId) async {
    await _service.markPrayed(duaId);
  }

  Future<void> deleteDua(String duaId) async {
    await _service.deleteDua(duaId);
  }
}
