import 'package:concession_tracker_ui/features/auth/presentation/pages/credits_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/order_summary_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/saved_item.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

import '../widgets/main_bottom_nav.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SavedScreen(),
    OrderSummaryPage(),
    CreditsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MainBottomNav(
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
