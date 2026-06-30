import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/quran_models.dart';
import 'package:vakitli/providers/quran_provider.dart';

enum QuranTheme { light, sepia, dark }

extension _QuranThemeX on QuranTheme {
  Color get background {
    switch (this) {
      case QuranTheme.light:
        return Colors.white;
      case QuranTheme.sepia:
        return const Color(0xFFFFF8E1);
      case QuranTheme.dark:
        return const Color(0xFF121212);
    }
  }

  Color get textColor {
    switch (this) {
      case QuranTheme.light:
        return const Color(0xFF212121);
      case QuranTheme.sepia:
        return const Color(0xFF4E342E);
      case QuranTheme.dark:
        return const Color(0xFFE8D5A3);
    }
  }

  Color get accentColor {
    switch (this) {
      case QuranTheme.light:
        return AppColors.primaryGreen;
      case QuranTheme.sepia:
        return const Color(0xFF6D4C41);
      case QuranTheme.dark:
        return AppColors.gold;
    }
  }

  Color get cardColor {
    switch (this) {
      case QuranTheme.light:
        return const Color(0xFFF5F5F5);
      case QuranTheme.sepia:
        return const Color(0xFFF0E4C0);
      case QuranTheme.dark:
        return const Color(0xFF1E1E2E);
    }
  }

  IconData get icon {
    switch (this) {
      case QuranTheme.light:
        return Icons.light_mode_rounded;
      case QuranTheme.sepia:
        return Icons.auto_stories_rounded;
      case QuranTheme.dark:
        return Icons.dark_mode_rounded;
    }
  }

  String get label {
    switch (this) {
      case QuranTheme.light:
        return 'Açık';
      case QuranTheme.sepia:
        return 'Sepia';
      case QuranTheme.dark:
        return 'Koyu';
    }
  }

  QuranTheme get next =>
      QuranTheme.values[(index + 1) % QuranTheme.values.length];
}

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
  static const String _themeKey = 'quran_theme';
  static const String _fontKey = 'quran_font_size';

  QuranTheme _theme = QuranTheme.light;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().saveLastRead(
            widget.surah.number,
            widget.initialAyah,
          );
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIdx =
        (prefs.getInt(_themeKey) ?? 0).clamp(0, QuranTheme.values.length - 1);
    final fontSize = (prefs.getDouble(_fontKey) ?? 24).clamp(_minFont, _maxFont);
    if (mounted) {
      setState(() {
        _theme = QuranTheme.values[themeIdx];
        _fontSize = fontSize;
      });
    }
  }

  Future<void> _cycleTheme() async {
    final next = _theme.next;
    setState(() => _theme = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, next.index);
  }

  Future<void> _setFontSize(double size) async {
    setState(() => _fontSize = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, size);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;
    final hasBismillah = surah.number != 1 && surah.number != 9;
    final bg = _theme.background;
    final tc = _theme.textColor;
    final ac = _theme.accentColor;
    final cc = _theme.cardColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: tc,
        iconTheme: IconThemeData(color: tc),
        title: Column(
          children: [
            Text(surah.turkishName, style: TextStyle(color: tc)),
            Text(
              surah.arabicName,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: tc.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_theme.icon, color: ac),
            tooltip: _theme.label,
            onPressed: _cycleTheme,
          ),
          IconButton(
            icon: Icon(Icons.text_decrease_rounded, color: ac),
            onPressed: _fontSize > _minFont
                ? () => _setFontSize(_fontSize - 2)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.text_increase_rounded, color: ac),
            onPressed: _fontSize < _maxFont
                ? () => _setFontSize(_fontSize + 2)
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
                        color: ac,
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
                  textColor: tc,
                  accentColor: ac,
                  cardColor: cc,
                );
              },
            ),
          ),
          _PageIndicator(surah: surah, bgColor: bg, textColor: tc),
        ],
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  final double fontSize;
  final Color textColor;
  final Color accentColor;
  final Color cardColor;

  const _AyahTile({
    required this.ayah,
    required this.surahNumber,
    required this.fontSize,
    required this.textColor,
    required this.accentColor,
    required this.cardColor,
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
            ? cardColor.withValues(alpha: 0.6)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context
                    .read<QuranProvider>()
                    .toggleBookmark(surahNumber, ayah.numberInSurah),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 18,
                  color: isBookmarked
                      ? AppColors.gold
                      : textColor.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sayfa ${ayah.page}',
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final Surah surah;
  final Color bgColor;
  final Color textColor;

  const _PageIndicator({
    required this.surah,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: bgColor,
      child: Text(
        '${surah.turkishName} — ${surah.ayahCount} ayet · '
        '${surah.isMeccan ? "Mekki" : "Medeni"}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: textColor.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
