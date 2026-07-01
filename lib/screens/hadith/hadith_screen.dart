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

class _HadithScreenState extends State<HadithScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'Koleksiyonlar'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: Consumer<HadithProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          if (provider.error != null && provider.allHadiths.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.lightText),
                    const SizedBox(height: 12),
                    Text(provider.error!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _DailyTab(provider: provider),
              _CollectionsTab(provider: provider),
              _FavoritesTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

// ─── Günün Hadisi ─────────────────────────────────────────────────────────────

class _DailyTab extends StatelessWidget {
  final HadithProvider provider;
  const _DailyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.dailyHadith == null) {
      return const Center(child: Text('Hadis bulunamadı.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _HadithCard(
            hadith: provider.dailyHadith!,
            provider: provider,
            isDaily: true,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.library_books_rounded,
                  size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Tüm Hadisler',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.allHadiths
              .map((h) => _HadithCard(hadith: h, provider: provider)),
        ],
      ),
    );
  }
}

// ─── Koleksiyonlar ────────────────────────────────────────────────────────────

class _CollectionsTab extends StatelessWidget {
  final HadithProvider provider;
  const _CollectionsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cats = provider.categories;

    if (cats.isEmpty) {
      return Center(
        child: provider.isApiLoading
            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: AppColors.lightText),
                  const SizedBox(height: 12),
                  Text('Kategoriler yüklenemedi.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('İnternet bağlantınızı kontrol edin.',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori chip'leri
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = cats[i];
              final isSelected = provider.selectedCategoryId == cat.id;
              return FilterChip(
                label: Text(cat.title),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) =>
                    context.read<HadithProvider>().selectCategory(cat.id),
              );
            },
          ),
        ),

        // Hadis listesi
        Expanded(
          child: _ApiHadithList(provider: provider),
        ),
      ],
    );
  }
}

class _ApiHadithList extends StatefulWidget {
  final HadithProvider provider;
  const _ApiHadithList({required this.provider});

  @override
  State<_ApiHadithList> createState() => _ApiHadithListState();
}

class _ApiHadithListState extends State<_ApiHadithList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 200) {
      widget.provider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    if (provider.selectedCategoryId == null) {
      return Center(
        child: Text(
          'Yukarıdan bir kategori seçin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lightText,
              ),
        ),
      );
    }

    if (provider.isApiLoading && provider.apiHadiths.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }

    if (provider.apiHadiths.isEmpty) {
      return Center(
        child: Text('Bu kategoride hadis bulunamadı.',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: provider.apiHadiths.length + (provider.hasMoreApiPages ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == provider.apiHadiths.length) {
          return provider.isApiLoading
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: provider.loadNextPage,
                      child: const Text('Daha Fazla Yükle'),
                    ),
                  ),
                );
        }
        return _HadithCard(
          hadith: provider.apiHadiths[i],
          provider: provider,
        );
      },
    );
  }
}

// ─── Favoriler ────────────────────────────────────────────────────────────────

class _FavoritesTab extends StatelessWidget {
  final HadithProvider provider;
  const _FavoritesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final favorites = provider.favoriteHadiths;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded,
                size: 64, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(
              'Henüz favori hadis eklemediniz.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightText),
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
      itemBuilder: (context, i) =>
          _HadithCard(hadith: favorites[i], provider: provider),
    );
  }
}

// ─── Hadis Kartı ──────────────────────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final HadithProvider provider;
  final bool isDaily;

  const _HadithCard({
    required this.hadith,
    required this.provider,
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = provider.isFavorite(hadith.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDaily
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDaily
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
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
          if (isDaily)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.gold, size: 18),
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
                // Konu + derece
                Row(
                  children: [
                    if (hadith.topic.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hadith.topic,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    if (hadith.grade != null && hadith.grade!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hadith.grade!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ],
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
                if (hadith.narrator.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hadith.narrator,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                if (hadith.narrator.isNotEmpty) const SizedBox(height: 4),

                // Kaynak
                if (hadith.source.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 16, color: AppColors.lightText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(hadith.source,
                            style: Theme.of(context).textTheme.bodySmall),
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
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : AppColors.lightText,
                      ),
                      tooltip:
                          isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                    ),
                    IconButton(
                      onPressed: () {
                        final shareText =
                            '"${hadith.text}"\n\n- ${hadith.narrator}\n📖 ${hadith.source}\n\n— Vakitli Uygulaması';
                        Share.share(shareText);
                      },
                      icon: const Icon(Icons.share_rounded,
                          color: AppColors.lightText),
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
