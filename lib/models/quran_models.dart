class Ayah {
  final int numberInSurah;
  final int page;
  final String text;

  const Ayah({
    required this.numberInSurah,
    required this.page,
    required this.text,
  });
}

class Surah {
  final int number;
  final String arabicName;
  final String turkishName;
  final String englishName;
  final bool isMeccan;
  final int ayahCount;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.arabicName,
    required this.turkishName,
    required this.englishName,
    required this.isMeccan,
    required this.ayahCount,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> j) {
    final List ayahsJson = j['ayahs'] as List;
    return Surah(
      number: j['n'] as int,
      arabicName: j['name'] as String,
      turkishName: j['tr'] as String,
      englishName: j['en'] as String,
      isMeccan: j['rev'] == 'M',
      ayahCount: j['count'] as int,
      ayahs: ayahsJson
          .map((a) => Ayah(
                numberInSurah: a['n'] as int,
                page: a['p'] as int,
                text: a['t'] as String,
              ))
          .toList(),
    );
  }
}

class QuranBookmark {
  final int surah;
  final int ayah;
  final DateTime savedAt;

  const QuranBookmark({
    required this.surah,
    required this.ayah,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'ayah': ayah,
        'savedAt': savedAt.millisecondsSinceEpoch,
      };

  factory QuranBookmark.fromJson(Map<String, dynamic> j) => QuranBookmark(
        surah: j['surah'] as int,
        ayah: j['ayah'] as int,
        savedAt: DateTime.fromMillisecondsSinceEpoch(j['savedAt'] as int),
      );
}
