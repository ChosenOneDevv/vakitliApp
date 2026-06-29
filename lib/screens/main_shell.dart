import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/screens/home/home_screen.dart';
import 'package:vakitli/screens/qibla/qibla_screen.dart';
import 'package:vakitli/screens/apps/apps_screen.dart';
import 'package:vakitli/widgets/radio_mini_player.dart';

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
  // Lazy IndexedStack: sadece ziyaret edilen sekme build edilir.
  final Set<int> _visited = {0};

  static const List<_TabItem> _tabs = [
    _TabItem(
      icon: Icons.mosque_outlined,
      activeIcon: Icons.mosque_rounded,
      label: 'Ana Sayfa',
      screen: HomeScreen(),
    ),
    _TabItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Kıble',
      screen: QiblaScreen(),
    ),
    _TabItem(
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      label: 'Uygulamalar',
      screen: AppsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  Widget build(BuildContext context) {
    _visited.add(_currentIndex);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: List.generate(_tabs.length, (i) {
                return _visited.contains(i)
                    ? _tabs[i].screen
                    : const SizedBox.shrink();
              }),
            ),
          ),
          const RadioMiniPlayer(),
        ],
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
          items: _tabs.map((item) {
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
