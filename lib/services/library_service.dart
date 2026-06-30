import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vakitli/models/library_book.dart';

/// Kütüphane özelliği şimdilik devre dışı (Firebase Storage Blaze plan gerektirir).
/// Tüm metotlar no-op veya boş sonuç döner.
class LibraryService {
  Stream<List<LibraryBook>> streamBooks() => const Stream.empty();

  Future<File> localFile(String bookId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/library/$bookId.pdf');
  }

  Future<bool> isDownloaded(String bookId) async => false;

  Future<String?> download(LibraryBook book) async {
    debugPrint('LibraryService.download: devre dışı');
    return null;
  }

  Future<void> deleteDownload(String bookId) async {}
}
