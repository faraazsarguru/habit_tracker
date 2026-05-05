import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import '../services/theme_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final navBg = isDark ? const Color(0xFF111111) : Colors.white;
    final navBorder = isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: navBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard', isDark),
                _buildNavItem(1, Icons.bar_chart_rounded, 'Statistics', isDark),
                _buildNavItem(2, Icons.person_rounded, 'Profile', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isActive = _currentIndex == index;
    const green = Color(0xFF00E676);
    final inactiveColor = isDark ? Colors.white24 : const Color(0xFF999999);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? green.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? green : inactiveColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? green : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
