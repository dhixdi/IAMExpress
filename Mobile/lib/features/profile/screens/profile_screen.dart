import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accent,
                    backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
                    child: user.photoUrl == null ? Text(user.nama[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white)) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(user.role, style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                  if (user.warehouseName != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(user.warehouseName!, style: const TextStyle(fontSize: 13, color: Colors.white60))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _SectionTitle('Akun'),
              _MenuItem(icon: Icons.lock_outline, label: 'Ganti Password', onTap: () => context.go(Routes.changePassword)),
              _MenuItem(icon: Icons.fingerprint, label: 'Pengaturan Biometrik', onTap: () => context.go(Routes.biometricSetting)),
              const SizedBox(height: 16),
              _SectionTitle('Tools TPM'),
              _MenuItem(icon: Icons.currency_exchange, label: 'Konversi Mata Uang', onTap: () => context.go(Routes.currency)),
              _MenuItem(icon: Icons.access_time, label: 'Konversi Waktu', onTap: () => context.go(Routes.timezone)),
              _MenuItem(icon: Icons.cloud_outlined, label: 'Cuaca', onTap: () => context.go(Routes.weather)),
              const SizedBox(height: 16),
              _SectionTitle('Lainnya'),
              _MenuItem(icon: Icons.sports_esports_outlined, label: 'Mini Game', onTap: () => context.go(Routes.miniGame)),
              _MenuItem(icon: Icons.rate_review_outlined, label: 'Saran & Kesan TPM', onTap: () => context.go(Routes.saranKesan)),
              _MenuItem(icon: Icons.logout, label: 'Logout', isDestructive: true, onTap: () {
                showModalBottomSheet(context: context, builder: (_) => ConfirmBottomSheet(
                  title: 'Logout', message: 'Yakin ingin keluar dari IAMExpress?', confirmLabel: 'Logout', isDestructive: true,
                  onConfirm: () async { await performLogout(ref); if (context.mounted) context.go(Routes.login); },
                ));
              }),
            ])),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8, top: 4), child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)));
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isDestructive;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 4),
    child: ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.danger : AppColors.primary),
      title: Text(label, style: TextStyle(color: isDestructive ? AppColors.danger : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    ),
  );
}
