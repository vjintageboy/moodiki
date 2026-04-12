import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mood/mood_history_page.dart';
import '../profile/profile_page.dart';
import '../news/news_feed_page.dart';
import '../../core/services/localization_service.dart';
import '../../core/constants/app_colors.dart';
import 'new_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pages = [
    NewHomePage(),
    MoodHistoryPage(),
    NewsFeedPage(),
    ProfilePage(),
  ];

  void _onTabTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.osSurface,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _OsBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// ============================================================================
// ORGANIC SANCTUARY BOTTOM NAV
// ============================================================================
class _OsBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _OsBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final items = [
      _NavItem(icon: Icons.home_outlined, filledIcon: Icons.home_rounded, label: context.l10n.home),
      _NavItem(icon: Icons.analytics_outlined, filledIcon: Icons.analytics_rounded, label: 'Insights'),
      _NavItem(icon: Icons.group_outlined, filledIcon: Icons.group_rounded, label: context.l10n.community),
      _NavItem(icon: Icons.person_outline_rounded, filledIcon: Icons.person_rounded, label: context.l10n.profile),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.osSurface.withValues(alpha: 0.70),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.osOnSurface.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding > 0 ? 0 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isSelected = selectedIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: AppColors.osPrimary,
                                borderRadius: BorderRadius.circular(999),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.filledIcon : item.icon,
                              color: isSelected
                                  ? AppColors.osOnPrimary
                                  : AppColors.osOnSurface.withValues(alpha: 0.55),
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.osOnPrimary
                                    : AppColors.osOnSurface.withValues(alpha: 0.55),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  const _NavItem({required this.icon, required this.filledIcon, required this.label});
}
