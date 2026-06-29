import 'package:cloud_firestore/cloud_firestore.dart';

class DuaKardesligi {
  final String id;
  final String duaText;
  final String fromUserId;
  final String fromUserName;
  final bool isAnonymous;
  final DateTime createdAt;
  final int prayedCount;
  final bool myPrayed;

  DuaKardesligi({
    required this.id,
    required this.duaText,
    required this.fromUserId,
    required this.fromUserName,
    this.isAnonymous = false,
    required this.createdAt,
    this.prayedCount = 0,
    this.myPrayed = false,
  });

  factory DuaKardesligi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DuaKardesligi(
      id: doc.id,
      duaText: data['duaText'] as String? ?? '',
      fromUserId: data['fromUserId'] as String? ?? '',
      fromUserName: data['fromUserName'] as String? ?? 'Anonim',
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      prayedCount: data['prayedCount'] as int? ?? 0,
      myPrayed: data['myPrayed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'duaText': duaText,
        'fromUserId': fromUserId,
        'fromUserName': isAnonymous ? 'Anonim' : fromUserName,
        'isAnonymous': isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'prayedCount': 0,
      };

  String get displayName => isAnonymous ? 'Anonim' : fromUserName;
}
