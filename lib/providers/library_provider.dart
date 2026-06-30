import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vakitli/models/library_book.dart';
import 'package:vakitli/services/library_service.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryService _service = LibraryService();

  StreamSubscription<List<LibraryBook>>? _sub;
  List<LibraryBook> _books = [];
  final Set<String> _downloaded = {};
  final Set<String> _downloading = {};
  bool _isLoading = true;
  String? _error;

  List<LibraryBook> get books => List.unmodifiable(_books);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isDownloaded(String id) => _downloaded.contains(id);
  bool isDownloading(String id) => _downloading.contains(id);

  void initialize() {
    _sub = _service.streamBooks().listen(
      (books) async {
        _books = books;
        _isLoading = false;
        _error = null;
        // İndirilmiş dosyaları tespit et.
        for (final b in books) {
          if (await _service.isDownloaded(b.id)) {
            _downloaded.add(b.id);
          }
        }
        notifyListeners();
      },
      onError: (Object e) {
        _isLoading = false;
        _error = 'Kütüphane yüklenemedi.';
        notifyListeners();
      },
    );
  }

  Future<String?> download(LibraryBook book) async {
    if (_downloading.contains(book.id)) return null;
    _downloading.add(book.id);
    notifyListeners();

    final path = await _service.download(book);

    _downloading.remove(book.id);
    if (path != null) {
      _downloaded.add(book.id);
    }
    notifyListeners();
    return path;
  }

  Future<String?> localPath(String bookId) async {
    final file = await _service.localFile(bookId);
    return await file.exists() ? file.path : null;
  }

  Future<void> deleteDownload(String bookId) async {
    await _service.deleteDownload(bookId);
    _downloaded.remove(bookId);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
