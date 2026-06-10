import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const _items = [
    (label: 'Dashboard', icon: Icons.dashboard_outlined, route: Routes.dashboard),
    (label: 'Paket', icon: Icons.inventory_2_outlined, route: Routes.packages),
    (label: 'Peta', icon: Icons.map_outlined, route: Routes.peta),
    (label: 'AI Chat', icon: Icons.smart_toy_outlined, route: Routes.aiChat),
    (label: 'Profil', icon: Icons.person_outline, route: Routes.profile),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/packages')) return 1;
    if (location.startsWith('/peta')) return 2;
    if (location.startsWith('/ai-chat')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return NavigationBar(
      selectedIndex: idx,
      onDestinationSelected: (i) => context.go(_items[i].route),
      destinations: _items.map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }
}
