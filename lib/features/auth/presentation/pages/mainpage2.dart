import 'package:flutter/material.dart';
import 'home_page.dart';

import 'saved_item.dart';
import 'order_summary_page.dart';
import 'myorders.dart';
import '../widgets/main_bottom_nav.dart';

class MainShellPage1 extends StatefulWidget {
  const MainShellPage1({super.key});

  @override
  State<MainShellPage1> createState() => _MainShellPage1State();
}

class _MainShellPage1State extends State<MainShellPage1> {
  int _currentIndex = 0;

  // 🔥 IMPORTANT: Home & StoreMenu are both here
  final List<Widget> _pages = [
    const HomePage(),
    const SavedScreen(),
    const OrderSummaryPage(), // Cart
    const MyOrdersPage(),     // Orders
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // ✅ Bottom bar appears only here
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
