import 'package:fin_track/features/dashboard/ui/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../category/presentation/ui/category_screen.dart';
import '../settings/ui/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const HomeScreen({super.key, this.onLocaleChange});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardScreen(onLocaleChange: widget.onLocaleChange),
          const CategoryScreen(),
          SettingScreen(onLocaleChange: widget.onLocaleChange),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFFDFF7E2),
            selectedItemColor: Color(0xFF00D09E),
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
              BottomNavigationBarItem(icon: const Icon(Icons.category_outlined), label: l10n.category),
              BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.setting),
            ],
          ),
        ),
      ),
    );
  }
}