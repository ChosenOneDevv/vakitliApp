import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:vakitli/config/theme.dart';

/// İndirilmiş bir kitabın PDF okuyucusu.
class BookReaderScreen extends StatefulWidget {
  final String title;
  final String filePath;

  const BookReaderScreen({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _ready = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _ready && _error == null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                        color: AppColors.lightGold, fontSize: 13),
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          if (_error == null)
            PDFView(
              filePath: widget.filePath,
              swipeHorizontal: false,
              onRender: (pages) => setState(() {
                _totalPages = pages ?? 0;
                _ready = true;
              }),
              onPageChanged: (page, _) =>
                  setState(() => _currentPage = page ?? 0),
              onError: (e) => setState(() => _error = '$e'),
              onPageError: (page, e) => setState(() => _error = '$e'),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Kitap açılamadı.\n$_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.lightText),
                ),
              ),
            )
          else if (!_ready)
            Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
    );
  }
}
