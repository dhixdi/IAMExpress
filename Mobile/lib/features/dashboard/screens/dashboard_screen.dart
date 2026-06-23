import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/stats_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_greeting()},', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(auth.user?.nama ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(auth.user?.role ?? '', style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: dashAsync.when(
                  loading: () => const LoadingOverlay(),
                  error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(dashboardProvider)),
                  data: (d) {
                    final role = auth.user?.role ?? '';
                    return Column(
                      children: [
                        if (role == 'SUPER_ADMIN') ...[
                          StatsCard(title: 'Total Gudang', value: d.totalWarehouse ?? 0, icon: Icons.warehouse_outlined, color: AppColors.info),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Total User', value: d.totalUser ?? 0, icon: Icons.people_outlined, color: AppColors.warning),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Paket Aktif', value: d.totalPaketAktif ?? 0, icon: Icons.inventory_2_outlined, color: AppColors.accent),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Total Delivered', value: d.totalDelivered ?? 0, icon: Icons.check_circle_outline, color: AppColors.success),
                        ] else if (role == 'WAREHOUSE_ADMIN') ...[
                          StatsCard(title: 'Paket di Gudang', value: d.paketDiWarehouse ?? 0, icon: Icons.inventory_outlined, color: AppColors.info),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Menunggu Linehaul', value: d.menungguLinehaul ?? 0, icon: Icons.local_shipping_outlined, color: AppColors.warning),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Menunggu Courier', value: d.menungguCourier ?? 0, icon: Icons.delivery_dining_outlined, color: AppColors.accent),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Delivered Hari Ini', value: d.deliveredHariIni ?? 0, icon: Icons.check_circle_outline, color: AppColors.success),
                        ] else ...[
                          StatsCard(title: 'Total Ditugaskan', value: d.totalDitugaskan, icon: Icons.assignment_outlined, color: AppColors.info),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Sedang Dikerjakan', value: d.sedangDikerjakan, icon: Icons.local_shipping_outlined, color: AppColors.warning),
                          const SizedBox(height: 8),
                          StatsCard(title: 'Selesai Hari Ini', value: d.selesaiHariIni, icon: Icons.check_circle_outline, color: AppColors.success),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(Routes.packages),
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: Text(role == 'SUPER_ADMIN' || role == 'WAREHOUSE_ADMIN' ? 'Lihat Semua Paket' : 'Lihat Paket Saya'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
