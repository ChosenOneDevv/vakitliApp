import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/quran_models.dart';
import 'package:vakitli/providers/quran_provider.dart';

class SurahScreen extends StatefulWidget {
  final Surah surah;
  final int initialAyah;

  const SurahScreen({super.key, required this.surah, this.initialAyah = 1});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final ScrollController _scroll = ScrollController();
  double _fontSize = 24;
  static const double _minFont = 18;
  static const double _maxFont = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Save last read position
      context.read<QuranProvider>().saveLastRead(
            widget.surah.number,
            widget.initialAyah,
          );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;
    final hasBismillah =
        surah.number != 1 && surah.number != 9; // Fatiha zaten içinde, Tevbe'de yok

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(surah.turkishName),
            Text(
              surah.arabicName,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: _fontSize > _minFont
                ? () => setState(() => _fontSize -= 2)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: _fontSize < _maxFont
                ? () => setState(() => _fontSize += 2)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: surah.ayahs.length + (hasBismillah ? 1 : 0),
              itemBuilder: (context, index) {
                if (hasBismillah && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: _fontSize + 2,
                        color: AppColors.primaryGreen,
                        height: 2.0,
                      ),
                    ),
                  );
                }
                final ayahIndex = hasBismillah ? index - 1 : index;
                final ayah = surah.ayahs[ayahIndex];
                return _AyahTile(
                  ayah: ayah,
                  surahNumber: surah.number,
                  fontSize: _fontSize,
                );
              },
            ),
          ),
          _PageIndicator(surah: surah),
        ],
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  final double fontSize;

  const _AyahTile({
    required this.ayah,
    required this.surahNumber,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isBookmarked = context
        .watch<QuranProvider>()
        .isBookmarked(surahNumber, ayah.numberInSurah);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: ayah.numberInSurah % 2 == 0
            ? Theme.of(context).cardColor.withValues(alpha: 0.6)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ayet numarası
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Yer imi butonu
              GestureDetector(
                onTap: () => context
                    .read<QuranProvider>()
                    .toggleBookmark(surahNumber, ayah.numberInSurah),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 18,
                  color: isBookmarked ? AppColors.gold : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ayet metni
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: ayah.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayet kopyalandı.')),
              );
            },
            child: Text(
              '${ayah.text} ۝',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: fontSize,
                height: 1.8,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sayfa ${ayah.page}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final Surah surah;

  const _PageIndicator({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        '${surah.turkishName} — ${surah.ayahCount} ayet · '
        '${surah.isMeccan ? "Mekki" : "Medeni"}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
      ),
    );
  }
}
