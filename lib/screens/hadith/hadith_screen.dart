import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/hadith.dart';
import 'package:vakitli/providers/hadith_provider.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadis-i Şerif'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Günün Hadisi'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: Consumer<HadithProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.lightText),
                    const SizedBox(height: 12),
                    Text(provider.error!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyTab(context, provider),
              _buildFavoritesTab(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyTab(BuildContext context, HadithProvider provider) {
    if (provider.dailyHadith == null) {
      return const Center(child: Text('Hadis bulunamadı.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildHadithCard(context, provider.dailyHadith!, provider, isDaily: true),
          const SizedBox(height: 24),

          // Tüm hadisler başlığı
          Row(
            children: [
              const Icon(Icons.library_books_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Tüm Hadisler', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),

          ...provider.allHadiths.map((hadith) =>
              _buildHadithCard(context, hadith, provider)),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, HadithProvider provider) {
    final favorites = provider.favoriteHadiths;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(
              'Henüz favori hadis eklemediniz.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beğendiğiniz hadislerin yanındaki ❤ simgesine dokunun.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) =>
          _buildHadithCard(context, favorites[index], provider),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    Hadith hadith,
    HadithProvider provider, {
    bool isDaily = false,
  }) {
    final isFav = provider.isFavorite(hadith.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDaily
            ? AppColors.primaryGreen.withValues(alpha: 0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDaily
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : AppColors.darkCream,
          width: isDaily ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık çubuğu
          if (isDaily)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Günün Hadisi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konu etiketi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hadith.topic,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Hadis metni
                Text(
                  '"${hadith.text}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 12),

                // Ravi
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hadith.narrator,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Kaynak
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 16, color: AppColors.lightText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hadith.source,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => provider.toggleFavorite(hadith.id),
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : AppColors.lightText,
                      ),
                      tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                    ),
                    IconButton(
                      onPressed: () {
                        final shareText =
                            '"${hadith.text}"\n\n- ${hadith.narrator}\n📖 ${hadith.source}\n\n— Vakitli Uygulaması';
                        Share.share(shareText);
                      },
                      icon: const Icon(Icons.share_rounded, color: AppColors.lightText),
                      tooltip: 'Paylaş',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
