import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  List<({String label, IconData icon, String route})> _itemsForRole(String role) {
    if (role == 'SUPER_ADMIN') {
      return [
        (label: 'Dashboard', icon: Icons.dashboard_outlined, route: Routes.dashboard),
        (label: 'Paket', icon: Icons.inventory_2_outlined, route: Routes.packages),
        (label: 'Gudang', icon: Icons.warehouse_outlined, route: Routes.warehouses),
        (label: 'Users', icon: Icons.people_outlined, route: Routes.users),
        (label: 'Profil', icon: Icons.person_outline, route: Routes.profile),
      ];
    }
    if (role == 'WAREHOUSE_ADMIN') {
      return [
        (label: 'Dashboard', icon: Icons.dashboard_outlined, route: Routes.dashboard),
        (label: 'Paket', icon: Icons.inventory_2_outlined, route: Routes.packages),
        (label: 'Peta', icon: Icons.map_outlined, route: Routes.peta),
        (label: 'Users', icon: Icons.people_outlined, route: Routes.users),
        (label: 'Profil', icon: Icons.person_outline, route: Routes.profile),
      ];
    }
    // LINEHAUL & COURIER
    return [
      (label: 'Dashboard', icon: Icons.dashboard_outlined, route: Routes.dashboard),
      (label: 'Paket', icon: Icons.inventory_2_outlined, route: Routes.packages),
      (label: 'Peta', icon: Icons.map_outlined, route: Routes.peta),
      (label: 'AI Chat', icon: Icons.smart_toy_outlined, route: Routes.aiChat),
      (label: 'Profil', icon: Icons.person_outline, route: Routes.profile),
    ];
  }

  int _currentIndex(BuildContext context, List<({String label, IconData icon, String route})> items) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == '/' && location == '/') return i;
      if (items[i].route != '/' && location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role ?? '';
    final items = _itemsForRole(role);
    final idx = _currentIndex(context, items);
    return NavigationBar(
      selectedIndex: idx,
      onDestinationSelected: (i) => context.go(items[i].route),
      destinations: items.map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }
}
