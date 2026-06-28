import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/qibla_provider.dart';
import 'package:vakitli/screens/home/home_screen.dart';
import 'package:vakitli/screens/qibla/qibla_screen.dart';
import 'package:vakitli/screens/tracker/tracker_screen.dart';
import 'package:vakitli/screens/tasbih/tasbih_screen.dart';
import 'package:vakitli/screens/hadith/hadith_screen.dart';
import 'package:vakitli/screens/settings/settings_screen.dart';

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _hasCompass = false;
  // Lazy IndexedStack: sadece ziyaret edilen sekme build edilir. Açılışta 6
  // ekranın hepsini birden build etmek startup lag yapıyordu.
  final Set<int> _visited = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCompass();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama öne gelince vakitleri tazele (gün dönümü → bildirim yeniden kurulur).
    if (state == AppLifecycleState.resumed) {
      context.read<PrayerProvider>().fetchTodayPrayerTimes();
    }
  }

  Future<void> _checkCompass() async {
    final available = await QiblaProvider.checkCompassAvailability();
    if (mounted && available != _hasCompass) {
      setState(() {
        _hasCompass = available;
      });
    }
  }

  List<_TabItem> get _tabs {
    final tabs = <_TabItem>[
      const _TabItem(
        icon: Icons.mosque_outlined,
        activeIcon: Icons.mosque_rounded,
        label: 'Vakitler',
        screen: HomeScreen(),
      ),
    ];

    if (_hasCompass) {
      tabs.add(const _TabItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Kıble',
        screen: QiblaScreen(),
      ));
    }

    tabs.addAll(const [
      _TabItem(
        icon: Icons.check_circle_outline_rounded,
        activeIcon: Icons.check_circle_rounded,
        label: 'Takip',
        screen: TrackerScreen(),
      ),
      _TabItem(
        icon: Icons.radio_button_checked_rounded,
        activeIcon: Icons.radio_button_checked_rounded,
        label: 'Tesbih',
        screen: TasbihScreen(),
      ),
      _TabItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: 'Hadis',
        screen: HadithScreen(),
      ),
      _TabItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Ayarlar',
        screen: SettingsScreen(),
      ),
    ]);

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    _visited.add(_currentIndex);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(tabs.length, (i) {
          // Ziyaret edilmemiş sekme boş kalır; ilk açıldığında build edilir.
          return _visited.contains(i)
              ? tabs[i].screen
              : const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: tabs.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
