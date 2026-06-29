import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudSyncService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? get _profileRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  static Future<void> saveProfile({
    required String displayName,
    required String gender,
    required String city,
    required double lat,
    required double lng,
  }) async {
    final ref = _profileRef;
    if (ref == null) return;
    await ref.set({
      'displayName': displayName,
      'gender': gender,
      'city': city,
      'lat': lat,
      'lng': lng,
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> fetchProfile() async {
    final ref = _profileRef;
    if (ref == null) return null;
    try {
      final snap = await ref.get();
      return snap.data();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isOnboardingComplete() async {
    final data = await fetchProfile();
    return data?['onboardingComplete'] == true;
  }

  static Future<void> updateField(String key, dynamic value) async {
    final ref = _profileRef;
    if (ref == null) return;
    try {
      await ref.set({key: value, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true));
    } catch (_) {}
  }
}
