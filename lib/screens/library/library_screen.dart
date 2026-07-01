import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/library_book.dart';
import 'package:vakitli/providers/library_provider.dart';
import 'package:vakitli/screens/library/book_reader_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kütüphane')),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.lightText)),
              ),
            );
          }
          if (provider.books.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 64, color: AppColors.lightText),
                    SizedBox(height: 16),
                    Text('Henüz kitap eklenmemiş.',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.books.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _BookCard(book: provider.books[i]),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final LibraryBook book;

  const _BookCard({required this.book});

  Future<void> _open(BuildContext context, LibraryProvider provider) async {
    final path = await provider.localPath(book.id);
    if (path == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BookReaderScreen(title: book.title, filePath: path),
    ));
  }

  Future<void> _download(
      BuildContext context, LibraryProvider provider) async {
    final path = await provider.download(book);
    if (!context.mounted) return;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kitap indirilemedi.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BookReaderScreen(title: book.title, filePath: path),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final downloaded = provider.isDownloaded(book.id);
    final downloading = provider.isDownloading(book.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (book.author.isNotEmpty)
                    Text(book.author,
                        style: Theme.of(context).textTheme.bodySmall),
                  if (book.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(book.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  if (downloading)
                    SizedBox(
                      height: 32,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          SizedBox(width: 8),
                          Text('İndiriliyor…'),
                        ],
                      ),
                    )
                  else if (downloaded)
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => _open(context, provider),
                          icon: const Icon(Icons.chrome_reader_mode_rounded,
                              size: 18),
                          label: const Text('Oku'),
                          style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.lightText),
                          tooltip: 'İndirileni sil',
                          onPressed: () => provider.deleteDownload(book.id),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _download(context, provider),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('İndir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side:
                            BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
