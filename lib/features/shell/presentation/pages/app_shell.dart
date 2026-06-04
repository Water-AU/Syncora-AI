import 'package:flutter/material.dart';
import 'package:syncora_ai/core/audience/syncora_audience.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/features/palette/presentation/pages/palette_dashboard_page.dart';

class AppShell extends StatefulWidget {
  final AudienceProfile initialAudience;

  const AppShell({
    super.key,
    this.initialAudience = AudienceProfile.whiteCollar,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_activity_outlined),
                selectedIcon: Icon(Icons.local_activity),
                label: Text('Activity'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy),
                label: Text('AI'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text('Diet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                PaletteDashboardPage(activeScreen: AppScreen.home, initialAudience: widget.initialAudience),
                PaletteDashboardPage(activeScreen: AppScreen.activity, initialAudience: widget.initialAudience),
                PaletteDashboardPage(activeScreen: AppScreen.ai, initialAudience: widget.initialAudience),
                PaletteDashboardPage(activeScreen: AppScreen.diet, initialAudience: widget.initialAudience),
                PaletteDashboardPage(activeScreen: AppScreen.profile, initialAudience: widget.initialAudience),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
