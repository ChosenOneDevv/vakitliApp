import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vakitli/models/library_book.dart';

/// Kütüphane: kitap meta verisi Firestore'dan, PDF içeriği Firebase
/// Storage'dan gelir; indirilen PDF cihaza önbelleğe alınır (çevrimdışı okuma).
class LibraryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collection = 'library';

  /// Firestore'daki kitapları sıralı yayınlar.
  Stream<List<LibraryBook>> streamBooks() {
    return _db
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(LibraryBook.fromFirestore).toList());
  }

  /// Kitabın cihazdaki yerel PDF dosyası (indirilmemişse var olmaz).
  Future<File> localFile(String bookId) async {
    final dir = await getApplicationDocumentsDirectory();
    final libDir = Directory('${dir.path}/library');
    if (!await libDir.exists()) {
      await libDir.create(recursive: true);
    }
    return File('${libDir.path}/$bookId.pdf');
  }

  Future<bool> isDownloaded(String bookId) async {
    final file = await localFile(bookId);
    return file.exists();
  }

  /// PDF'i Storage'dan indirip yerel dosyaya yazar; dosya yolunu döner.
  /// Hata durumunda `null`.
  Future<String?> download(LibraryBook book) async {
    if (book.storagePath.isEmpty) return null;
    try {
      final file = await localFile(book.id);
      await _storage.ref(book.storagePath).writeToFile(file);
      return file.path;
    } catch (e) {
      debugPrint('LibraryService.download hata: $e');
      return null;
    }
  }

  Future<void> deleteDownload(String bookId) async {
    try {
      final file = await localFile(bookId);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('LibraryService.deleteDownload hata: $e');
    }
  }
}
