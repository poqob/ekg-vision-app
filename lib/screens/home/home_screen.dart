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
      bottomNavigationBar: BottomNavigationBar(
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : null,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade700,
        onTap: _onItemTapped,
      ),
    );
  }
}
