import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/packages/screens/package_list_screen.dart';
import 'features/packages/screens/package_detail_screen.dart';
import 'features/packages/screens/package_tracker_screen.dart';
import 'features/packages/screens/package_form_screen.dart';
import 'features/packages/screens/package_assign_screen.dart';
import 'features/peta/screens/peta_screen.dart';
import 'features/ai_chat/screens/ai_chat_screen.dart';
import 'features/users/screens/user_list_screen.dart';
import 'features/users/screens/user_form_screen.dart';
import 'features/warehouses/screens/warehouse_list_screen.dart';
import 'features/warehouses/screens/warehouse_form_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/change_password_screen.dart';
import 'features/profile/screens/biometric_setting_screen.dart';
import 'features/tools_tpm/currency/screens/currency_screen.dart';
import 'features/tools_tpm/timezone/screens/timezone_screen.dart';
import 'features/tools_tpm/weather/screens/weather_screen.dart';
import 'features/mini_game/screens/mini_game_screen.dart';
import 'features/saran_kesan/screens/saran_kesan_screen.dart';
import 'shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == Routes.login;

      if (!isLoggedIn && !isLoginRoute) return Routes.login;
      if (isLoggedIn && isLoginRoute) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.packages,
            builder: (_, __) => const PackageListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const PackageFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => PackageDetailScreen(
                  packageId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'tracker',
                    builder: (_, state) => PackageTrackerScreen(
                      packageId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => PackageFormScreen(
                      packageId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: 'assign',
                    builder: (_, state) => PackageAssignScreen(
                      packageId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(path: Routes.peta, builder: (_, __) => const PetaScreen()),
          GoRoute(path: Routes.aiChat, builder: (_, __) => const AiChatScreen()),
          GoRoute(
            path: Routes.users,
            builder: (_, __) => const UserListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const UserFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, state) => UserFormScreen(
                  userId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.warehouses,
            builder: (_, __) => const WarehouseListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const WarehouseFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, state) => WarehouseFormScreen(
                  warehouseId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: Routes.changePassword, builder: (_, __) => const ChangePasswordScreen()),
          GoRoute(path: Routes.biometricSetting, builder: (_, __) => const BiometricSettingScreen()),
          GoRoute(path: Routes.currency, builder: (_, __) => const CurrencyScreen()),
          GoRoute(path: Routes.timezone, builder: (_, __) => const TimezoneScreen()),
          GoRoute(path: Routes.weather, builder: (_, __) => const WeatherScreen()),
          GoRoute(path: Routes.miniGame, builder: (_, __) => const MiniGameScreen()),
          GoRoute(path: Routes.saranKesan, builder: (_, __) => const SaranKesanScreen()),
        ],
      ),
    ],
  );
});

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Coba restore session saat app mulai
    Future.microtask(() => restoreSession(ref));
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'IAMExpress',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
