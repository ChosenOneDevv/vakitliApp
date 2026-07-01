import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/tebrik_card.dart';
import 'package:vakitli/providers/tebrik_provider.dart';

class TebrikScreen extends StatelessWidget {
  const TebrikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tebrik Kartları'),
        actions: [
          Consumer<TebrikProvider>(
            builder: (_, provider, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: provider.isLoading ? null : provider.refresh,
              tooltip: 'Yenile',
            ),
          ),
        ],
      ),
      body: Consumer<TebrikProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.cards.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.cards.length,
            itemBuilder: (context, i) => _TebrikTile(card: provider.cards[i]),
          );
        },
      ),
    );
  }
}

class _TebrikTile extends StatelessWidget {
  final TebrikCard card;

  const _TebrikTile({required this.card});

  static final List<Color> _colors = [
    AppColors.primaryGreen,
    AppColors.navy,
    AppColors.gold,
    Color(0xFF6A1B9A),
    Color(0xFF00695C),
    Color(0xFFC62828),
    Color(0xFF1565C0),
    Color(0xFF558B2F),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[card.id % _colors.length];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showCard(context),
        child: _buildContent(color),
      ),
    );
  }

  Widget _buildContent(Color color) {
    // Network image (Firestore kart)
    if (card.imageUrl != null && card.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            card.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(color),
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    color: color.withValues(alpha: 0.15),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                card.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Local asset
    if (card.imagePath != null) {
      return Image.asset(card.imagePath!, fit: BoxFit.cover);
    }

    return _placeholder(color);
  }

  Widget _placeholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mosque_rounded, color: Colors.white70, size: 32),
            const SizedBox(height: 10),
            Text(
              card.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCard(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  card.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
              const SizedBox(height: 16),
            Text(
              card.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              card.shareText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share_rounded),
                label: const Text('Paylaş'),
                onPressed: () =>
                    Share.share(card.shareText, subject: card.title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
