import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vakitli/models/dua_kardesligi.dart';

class DuaKardesligiService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String _collection = 'duaKardesligi';

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<DuaKardesligi>> streamAll() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map(DuaKardesligi.fromFirestore).toList());
  }

  Stream<List<DuaKardesligi>> streamMine() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection(_collection)
        .where('fromUserId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(DuaKardesligi.fromFirestore).toList());
  }

  Future<String?> addDua({
    required String duaText,
    required String userName,
    bool isAnonymous = false,
  }) async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      final ref = await _db.collection(_collection).add({
        'duaText': duaText.trim(),
        'fromUserId': uid,
        'fromUserName': isAnonymous ? 'Anonim' : userName,
        'isAnonymous': isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'prayedCount': 0,
        'prayedBy': [],
      });
      return ref.id;
    } catch (e) {
      debugPrint('DuaKardesligiService.addDua hata: $e');
      return null;
    }
  }

  Future<void> markPrayed(String duaId) async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await _db.collection(_collection).doc(duaId).update({
        'prayedCount': FieldValue.increment(1),
        'prayedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      debugPrint('DuaKardesligiService.markPrayed hata: $e');
    }
  }

  Future<bool> hasPrayed(String duaId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final doc = await _db.collection(_collection).doc(duaId).get();
      final prayedBy = (doc.data()?['prayedBy'] as List?)?.cast<String>() ?? [];
      return prayedBy.contains(uid);
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteDua(String duaId) async {
    try {
      await _db.collection(_collection).doc(duaId).delete();
    } catch (e) {
      debugPrint('DuaKardesligiService.deleteDua hata: $e');
    }
  }
}
