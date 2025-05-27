import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../analysis/analysis_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define screens to display
  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalysisScreen(),
    ProfileScreen(),
  ];

  // Navigation titles
  final List<String> _titles = const ['Scanning', 'Analysis', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Update the global app state if needed
    // AppStateProvider.of(context).setCurrentTab(index);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building HomeScreen');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      // Island-style floating bottom navigation bar
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
        child: PhysicalModel(
          color: Colors.transparent,
          elevation: 16,
          borderRadius: BorderRadius.circular(32),
          shadowColor: Colors.black.withOpacity(0.2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900
                        : Colors.white),
                borderRadius: BorderRadius.circular(32),
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.monitor_heart_rounded),
                    label: 'Scanning',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: 'Analysis',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.transparent,
                elevation: 0,
                unselectedItemColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
