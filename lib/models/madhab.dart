enum Madhab {
  hanafi,
  shafii,
  maliki,
  hanbali;

  String get label {
    switch (this) {
      case Madhab.hanafi:
        return 'Hanefî';
      case Madhab.shafii:
        return 'Şâfiî';
      case Madhab.maliki:
        return 'Mâlikî';
      case Madhab.hanbali:
        return 'Hanbelî';
    }
  }

  /// Aladhan API `school` parametresi. Hanefî ikindi vakti için 1, diğerleri 0.
  int get asrSchool => this == Madhab.hanafi ? 1 : 0;

  /// Vitir namazı Hanefî'de vacip; diğer mezheplerde sünnet.
  bool get isViterWajib => this == Madhab.hanafi;

  static Madhab fromName(String name) => Madhab.values.firstWhere(
        (m) => m.name == name,
        orElse: () => Madhab.hanafi,
      );
}
