import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _loading = false;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  StreamSubscription<User?>? _sub;

  void initialize() {
    _sub = _auth.authStateChanges().listen((user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _localizeError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _localizeError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _localizeError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Google ile giriş başarısız.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _localizeError(String code) {
    return switch (code) {
      'user-not-found' => 'Bu e-posta ile kayıtlı hesap bulunamadı.',
      'wrong-password' => 'Şifre hatalı.',
      'email-already-in-use' => 'Bu e-posta zaten kayıtlı.',
      'weak-password' => 'Şifre en az 6 karakter olmalı.',
      'invalid-email' => 'Geçerli bir e-posta adresi girin.',
      'too-many-requests' => 'Çok fazla deneme. Lütfen bekleyin.',
      'network-request-failed' => 'İnternet bağlantısı yok.',
      'invalid-credential' => 'E-posta veya şifre hatalı.',
      _ => 'Bir hata oluştu. Tekrar deneyin.',
    };
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
