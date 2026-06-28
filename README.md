# Vakitli 🕌

Namaz vakitlerini takip eden, alarm/bildirim yöneten, günlük hadis ve dua sunan İslami yaşam uygulaması. Flutter ile geliştirilmiştir (Android + iOS), arayüz tamamen Türkçedir.

## Özellikler

- **Namaz Vakitleri** — Aladhan API ile günlük vakitler, sonraki vakte geri sayım, Hicri + Miladi tarih. 10 hesaplama metodu (varsayılan: Diyanet).
- **Konum** — GPS ile otomatik tespit veya 81 il arasından manuel seçim.
- **Alarm/Bildirim** — her vakit için ayrı alarm ("vaktinde" / "önce" modları), bugün + yarın otomatik zamanlama, yeniden başlatma sonrası kurtarma.
- **Kıble Pusulası** — cihaz sensörüyle Kâbe yönü ve mesafe.
- **Namaz Takip** — günlük 5 vakit işaretleme, ardışık gün serisi (streak), haftalık/aylık istatistik.
- **Tesbih Sayacı** — çoklu profil, hedef (33/99/özel), titreşim geri bildirimi.
- **Günlük Hadis** — 40 hadis, favori + paylaşım.
- **Dua/Zikir** — kategorili koleksiyon, Arapça + okunuş + anlam, arama + favori.
- **Ayarlar** — hesaplama metodu, Hicri tarih ofseti, tema (Açık/Koyu/Sistem), veri sıfırlama.
- **Çevrimdışı** — vakitler önbelleğe alınır; internet yokken son veriler gösterilir.

## Teknik Yığın

- **Flutter / Dart** (SDK ^3.11.3)
- **State**: Provider (`ChangeNotifier`, `ChangeNotifierProxyProvider`)
- **Depolama**: SharedPreferences (+ vakit önbelleği)
- **API**: Aladhan (namaz vakitleri), yerel JSON (hadis, dua)
- **Bildirim**: flutter_local_notifications + timezone
- **Konum/Sensör**: geolocator, geocoding, flutter_compass
- **Tipografi**: Amiri + Cairo (bundle font)

## Kurulum

```bash
flutter pub get
flutter run
```

## Geliştirme

```bash
flutter analyze   # statik analiz (0 uyarı beklenir)
flutter test      # birim + widget testleri
```

CI: her push/PR'da GitHub Actions `analyze` + `test` çalıştırır (`.github/workflows/flutter.yml`).

## Derleme

```bash
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

## Proje Yapısı

```
lib/
  config/     tema, sabitler
  models/     veri sınıfları
  services/   API/platform I/O
  providers/  state (ChangeNotifier)
  screens/    sayfalar
  widgets/    paylaşılan widget'lar
  data/       statik veri (iller)
```

Ayrıntılı yol haritası ve iyileştirme planı için [progress.md](progress.md), geliştirme kuralları için [CLAUDE.md](CLAUDE.md).
