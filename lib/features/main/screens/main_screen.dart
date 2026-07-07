import 'package:flutter/material.dart';
import 'package:flashcard/core/widgets/custom_bottom_nav_bar.dart';
import 'package:flashcard/features/subject/screens/subject_screen.dart';
import 'package:flashcard/features/statistics/screens/statistics_screen.dart';
import 'package:flashcard/features/profile/screens/profile_screen.dart';
import 'package:flashcard/features/library/screens/library_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SubjectListScreen(),
    const LibraryScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
