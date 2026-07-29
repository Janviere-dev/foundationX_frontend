import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/features/home/screens/home_screen.dart';
import 'package:foundationx_frontend/features/subjects/screens/subjects_screen.dart';
import 'package:foundationx_frontend/features/progress/screens/progress_screen.dart';
import 'package:foundationx_frontend/features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  late final List<Widget> _screens = [
    HomeScreen(onNavigateToTab: _goToTab),
    const SubjectsScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,

          type: BottomNavigationBarType.fixed,
          elevation: 12,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF8E98A8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Subjects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
