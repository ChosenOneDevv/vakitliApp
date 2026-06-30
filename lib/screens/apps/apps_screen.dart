import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/screens/tracker/tracker_screen.dart';
import 'package:vakitli/screens/qada/qada_screen.dart';
import 'package:vakitli/screens/ramadan/ramadan_screen.dart';
import 'package:vakitli/screens/esma/esma_screen.dart';
import 'package:vakitli/screens/zakat/zakat_screen.dart';
import 'package:vakitli/screens/mosque/mosque_screen.dart';
import 'package:vakitli/screens/location/saved_cities_screen.dart';
import 'package:vakitli/screens/hijri/hijri_calendar_screen.dart';
import 'package:vakitli/screens/nafile/nafile_screen.dart';
import 'package:vakitli/screens/tasbih/tasbih_screen.dart';
import 'package:vakitli/screens/hadith/hadith_screen.dart';
import 'package:vakitli/screens/duas/duas_screen.dart';
import 'package:vakitli/screens/female/female_screen.dart';
import 'package:vakitli/screens/settings/settings_screen.dart';
import 'package:vakitli/screens/sunnah/sunnah_screen.dart';
import 'package:vakitli/screens/radio/radio_screen.dart';
import 'package:vakitli/screens/hikmet/hikmet_screen.dart';
import 'package:vakitli/screens/amel/amel_screen.dart';
import 'package:vakitli/screens/tebrik/tebrik_screen.dart';
import 'package:vakitli/screens/hutbe/hutbe_screen.dart';
import 'package:vakitli/screens/dua_kardesligi/dua_kardesligi_screen.dart';
import 'package:vakitli/screens/quran/quran_screen.dart';
import 'package:vakitli/screens/hatim/hatim_screen.dart';
import 'package:vakitli/screens/library/library_screen.dart';

class _AppItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget screen;

  const _AppItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.screen,
  });
}

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  static const List<_AppItem> _items = [
    _AppItem(
      icon: Icons.menu_book_rounded,
      label: 'Kuran-ı Kerim',
      subtitle: '114 sure · Uthmani metin',
      screen: QuranScreen(),
    ),
    _AppItem(
      icon: Icons.auto_stories_rounded,
      label: 'Hatim Takibi',
      subtitle: 'Kuran okuma ilerlemesi',
      screen: HatimScreen(),
    ),
    _AppItem(
      icon: Icons.local_library_rounded,
      label: 'Kütüphane',
      subtitle: 'İndirilebilir kitaplar',
      screen: LibraryScreen(),
    ),
    _AppItem(
      icon: Icons.check_circle_rounded,
      label: 'Namaz Takip',
      subtitle: 'Günlük takip + istatistik',
      screen: TrackerScreen(),
    ),
    _AppItem(
      icon: Icons.radio_button_checked_rounded,
      label: 'Tesbih',
      subtitle: 'Zikir sayacı',
      screen: TasbihScreen(),
    ),
    _AppItem(
      icon: Icons.history_toggle_off_rounded,
      label: 'Kaza Namazı',
      subtitle: 'Kaza borç takibi',
      screen: QadaScreen(),
    ),
    _AppItem(
      icon: Icons.brightness_3_rounded,
      label: 'Nafile Takip',
      subtitle: 'Sünnet/nafile namaz',
      screen: NafileScreen(),
    ),
    _AppItem(
      icon: Icons.nightlight_round,
      label: 'Ramazan',
      subtitle: 'İmsak/iftar + oruç',
      screen: RamadanScreen(),
    ),
    _AppItem(
      icon: Icons.mosque_rounded,
      label: 'Cami Bulucu',
      subtitle: 'Yakındaki camiler',
      screen: MosqueScreen(),
    ),
    _AppItem(
      icon: Icons.location_city_rounded,
      label: 'Çoklu Şehir',
      subtitle: 'Farklı şehir vakitleri',
      screen: SavedCitiesScreen(),
    ),
    _AppItem(
      icon: Icons.spa_rounded,
      label: 'Esma-ül Hüsna',
      subtitle: 'Allah\'ın 99 ismi',
      screen: EsmaScreen(),
    ),
    _AppItem(
      icon: Icons.calculate_rounded,
      label: 'Zekat',
      subtitle: 'Zekat hesaplayıcı',
      screen: ZakatScreen(),
    ),
    _AppItem(
      icon: Icons.calendar_month_rounded,
      label: 'Hicri Takvim',
      subtitle: 'Takvim + dini günler',
      screen: HijriCalendarScreen(),
    ),
    _AppItem(
      icon: Icons.import_contacts_rounded,
      label: 'Sünnet Dersleri',
      subtitle: 'İbadet sünnetleri',
      screen: SunnahScreen(),
    ),
    _AppItem(
      icon: Icons.favorite_rounded,
      label: 'Kadın Köşesi',
      subtitle: 'Hükümler & hayız takip',
      screen: FemaleScreen(),
    ),
    _AppItem(
      icon: Icons.menu_book_rounded,
      label: 'Hadis',
      subtitle: 'Günün hadisi',
      screen: HadithScreen(),
    ),
    _AppItem(
      icon: Icons.auto_stories_rounded,
      label: 'Dua & Zikir',
      subtitle: 'Dua koleksiyonu',
      screen: DuasScreen(),
    ),
    _AppItem(
      icon: Icons.radio_rounded,
      label: 'Kuran Radyosu',
      subtitle: 'Canlı Kuran yayını',
      screen: RadioScreen(),
    ),
    _AppItem(
      icon: Icons.settings_rounded,
      label: 'Ayarlar',
      subtitle: 'Uygulama ayarları',
      screen: SettingsScreen(),
    ),
    _AppItem(
      icon: Icons.format_quote_rounded,
      label: 'Hikmetler',
      subtitle: 'İslami öğütler ve hikmetler',
      screen: HikmetScreen(),
    ),
    _AppItem(
      icon: Icons.edit_note_rounded,
      label: 'Amel Defteri',
      subtitle: 'Günlük ibadet kaydı',
      screen: AmelScreen(),
    ),
    _AppItem(
      icon: Icons.card_giftcard_rounded,
      label: 'Tebrik Kartları',
      subtitle: 'Kandil ve bayram tebriği',
      screen: TebrikScreen(),
    ),
    _AppItem(
      icon: Icons.record_voice_over_rounded,
      label: 'Cuma Hutbesi',
      subtitle: 'Haftanın hutbesi',
      screen: HutbeScreen(),
    ),
    _AppItem(
      icon: Icons.favorite_rounded,
      label: 'Dua Kardeşliği',
      subtitle: 'Dua istek paylaşımı',
      screen: DuaKardesligiScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uygulamalar')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) => _AppTile(item: _items[index]),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final _AppItem item;

  const _AppTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => item.screen),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon,
                    color: AppColors.primaryGreen, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
