import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<BottomNavItem> bottomNavItems = [
  BottomNavItem(
    icon: Icons.mosque_outlined,
    activeIcon: Icons.mosque_rounded,
    label: 'Vakitler',
  ),
  BottomNavItem(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    label: 'Kıble',
  ),
  BottomNavItem(
    icon: Icons.check_circle_outline_rounded,
    activeIcon: Icons.check_circle_rounded,
    label: 'Takip',
  ),
  BottomNavItem(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    label: 'Hadis',
  ),
  BottomNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Ayarlar',
  ),
];
