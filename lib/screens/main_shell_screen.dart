import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// unused import removed
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'command_center_screen.dart';
import 'insights_library_screen.dart';
import 'settings_screen.dart';
import 'activity_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {

  final List<Widget> _screens = const [
    CommandCenterScreen(),
    InsightsLibraryScreen(),
    ActivityScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          extendBody: false, // Solid layout for fixed nav
          body: IndexedStack(
            index: state.selectedTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white, 
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.1),
            height: 65,
            selectedIndex: state.selectedTabIndex,
            onDestinationSelected: (index) {
                state.setTabIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.house, size: 20),
                selectedIcon: Icon(FontAwesomeIcons.house, size: 20, color: AppTheme.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.bookOpen, size: 20),
                selectedIcon: Icon(FontAwesomeIcons.bookOpen, size: 20, color: AppTheme.primary),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.chartLine, size: 20),
                selectedIcon: Icon(FontAwesomeIcons.chartLine, size: 20, color: AppTheme.primary),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.gear, size: 20),
                selectedIcon: Icon(FontAwesomeIcons.gear, size: 20, color: AppTheme.primary),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
