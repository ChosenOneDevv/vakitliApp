import 'package:cloud_firestore/cloud_firestore.dart';

/// Kütüphanedeki bir kitap. İçerik (PDF) Firebase Storage'da, meta veri
/// Firestore `library` koleksiyonunda tutulur — yeni kitap eklemek için
/// uygulama güncellemesi gerekmez.
class LibraryBook {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;

  /// Firebase Storage içindeki PDF yolu (ör. `library/risale.pdf`).
  final String storagePath;

  /// Sıralama için (küçük → önce).
  final int order;

  const LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.storagePath,
    required this.order,
  });

  factory LibraryBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LibraryBook(
      id: doc.id,
      title: (data['title'] as String?) ?? 'İsimsiz',
      author: (data['author'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      storagePath: (data['storagePath'] as String?) ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
