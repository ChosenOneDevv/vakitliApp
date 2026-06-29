class TebrikCard {
  final int id;
  final String title;
  final String occasion;

  /// assets/images/cards/ içindeki dosya adı; null ise renkli metin kartı gösterilir.
  final String? imagePath;
  final String shareText;

  const TebrikCard({
    required this.id,
    required this.title,
    required this.occasion,
    this.imagePath,
    required this.shareText,
  });

  static const List<TebrikCard> defaults = [
    TebrikCard(
      id: 1,
      title: 'Ramazan Bayramı',
      occasion: 'Ramazan Bayramı',
      shareText:
          'Ramazan Bayramınız mübarek olsun! 🌙\nKalpleriniz ferah, sofranız bereketli olsun.',
    ),
    TebrikCard(
      id: 2,
      title: 'Kurban Bayramı',
      occasion: 'Kurban Bayramı',
      shareText:
          'Kurban Bayramınız mübarek olsun! 🕌\nKurbanlarınız ve dualarınız kabul olsun.',
    ),
    TebrikCard(
      id: 3,
      title: 'Mevlid Kandili',
      occasion: 'Mevlid Kandili',
      shareText:
          'Mevlid Kandili\'niz mübarek olsun! 🌟\nHz. Peygamberin (s.a.v.) sevgisi kalplerimizde daim olsun.',
    ),
    TebrikCard(
      id: 4,
      title: 'Regaip Kandili',
      occasion: 'Regaip Kandili',
      shareText:
          'Regaip Kandili\'niz mübarek olsun! ✨\nDualarınız kabul, günahlarınız affedilsin.',
    ),
    TebrikCard(
      id: 5,
      title: 'Berat Kandili',
      occasion: 'Berat Kandili',
      shareText:
          'Berat Kandili\'niz mübarek olsun! 🌙\nBu mübarek gecede dualarınız kabul olsun.',
    ),
    TebrikCard(
      id: 6,
      title: 'Kadir Gecesi',
      occasion: 'Kadir Gecesi',
      shareText:
          'Kadir Geceniz mübarek olsun! 🤲\nBin aydan hayırlı bu geceyi ihya etmeniz dileğiyle.',
    ),
    TebrikCard(
      id: 7,
      title: 'Arefe Günü',
      occasion: 'Arefe',
      shareText:
          'Arefe gününüz mübarek olsun! 🕋\nGünahların affı ve duaların kabulü umulan bu mübarek günde hepimize hayırlı olsun.',
    ),
    TebrikCard(
      id: 8,
      title: 'Cuma Mübarek',
      occasion: 'Cuma',
      shareText:
          'Cuma\'nız mübarek olsun! 🌿\nHaftalığın en hayırlı günü, duaların kabul vakti.',
    ),
  ];
}
