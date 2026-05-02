import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/liquid_glass.dart';
import 'activities_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = [
    ActivitiesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _GlassNavBar(
        selectedIndex: _currentIndex,
        onSelect: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _GlassNavBar({
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _items = [
    (icon: Icons.sports_outlined, activeIcon: Icons.sports_rounded, label: 'Activités'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 8, 48, 12),
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(50),
          blurSigma: 30,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = selectedIndex == i;
              return _NavItem(
                icon: item.icon,
                activeIcon: item.activeIcon,
                label: item.label,
                selected: selected,
                onTap: () => onSelect(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 14,
          vertical: 8,
        ),
        decoration: selected
            ? BoxDecoration(
                color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.18),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.35 : 0.30),
                  width: 0.8,
                ),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                color: selected
                    ? scheme.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.38)),
                size: 22,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Row(
                      children: [
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
