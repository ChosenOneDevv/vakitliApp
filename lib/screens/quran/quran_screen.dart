import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/quran_models.dart';
import 'package:vakitli/providers/quran_provider.dart';
import 'package:vakitli/screens/quran/surah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuran-ı Kerim'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Sure ara...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final surahs = provider.search(_query);
          final lastRead = provider.lastRead;

          return Column(
            children: [
              if (lastRead != null && _query.isEmpty)
                _LastReadBanner(
                  bookmark: lastRead,
                  surahName: provider.surahs.length >= lastRead.surah
                      ? provider.surahs[lastRead.surah - 1].turkishName
                      : '',
                  onTap: () => _openSurah(
                      context, provider.surahs[lastRead.surah - 1],
                      scrollToAyah: lastRead.ayah),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: surahs.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 56,
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (context, i) => _SurahTile(
                    surah: surahs[i],
                    onTap: () => _openSurah(context, surahs[i]),
                  ),
                ),
              ),
              _DisclaimerFooter(),
            ],
          );
        },
      ),
    );
  }

  void _openSurah(BuildContext context, Surah surah, {int scrollToAyah = 1}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahScreen(surah: surah, initialAyah: scrollToAyah),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.turkishName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${surah.ayahCount} ayet · ${surah.isMeccan ? "Mekki" : "Medeni"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              surah.arabicName,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

class _LastReadBanner extends StatelessWidget {
  final QuranBookmark bookmark;
  final String surahName;
  final VoidCallback onTap;

  const _LastReadBanner({
    required this.bookmark,
    required this.surahName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navy, Color(0xFF283593)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kaldığın yer',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '$surahName — ${bookmark.ayah}. ayet',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        'Metin kaynağı: tanzil.net (Hafs an Asım, Uthmani). '
        'Okuma ve ibadet için basılı mushafı esas alın.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
      ),
    );
  }
}
