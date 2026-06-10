import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/package_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/format_currency.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/package_detail_provider.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final int packageId;
  const PackageDetailScreen({super.key, required this.packageId});
  @override
  ConsumerState<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  bool _updating = false;
  String? _notes;

  Future<void> _openGoogleMaps(dynamic pkg) async {
    final destination = (pkg.receiverLat != null && pkg.receiverLng != null) 
        ? '${pkg.receiverLat},${pkg.receiverLng}' 
        : Uri.encodeComponent(pkg.alamatTujuan);
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destination');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _doUpdate(String status) async {
    setState(() => _updating = true);
    try {
      await updatePackageStatus(ref, widget.packageId, status, notes: _notes);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status diubah ke $status'), backgroundColor: AppColors.success));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    }
    setState(() { _updating = false; _notes = null; });
  }

  void _confirmUpdate(String status, {bool destructive = false, bool withNotes = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ConfirmBottomSheet(
        title: 'Update Status',
        message: 'Ubah status paket menjadi "$status"?',
        confirmLabel: 'Ya, Update',
        isDestructive: destructive,
        showNotesField: withNotes,
        onNotesChanged: (v) => _notes = v,
        onConfirm: () => _doUpdate(status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkgAsync = ref.watch(packageDetailProvider(widget.packageId));
    final role = ref.watch(authProvider).user?.role ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Paket')),
      body: pkgAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(packageDetailProvider(widget.packageId))),
        data: (pkg) {
          final nextStatuses = PackageStatus.nextStatuses(pkg.currentStatus, role);
          final isOutForDelivery = pkg.currentStatus == PackageStatus.outForDelivery && role == 'COURIER';
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(pkg.resi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                      StatusBadge(status: pkg.currentStatus),
                    ]),
                    const SizedBox(height: 20),
                    _section('Info Paket', [
                      if (pkg.destinationWarehouseName != null) _row('Rute (Gudang)', '${pkg.currentWarehouseName ?? "-"} ➔ ${pkg.destinationWarehouseName}'),
                      _row('Nama', pkg.namaPaket),
                      _row('Berat', '${pkg.berat} kg'),
                      _row('Layanan', pkg.jenisLayanan),
                      _row('Ongkos Kirim', formatCurrency(pkg.ongkosKirim)),
                      if (pkg.deskripsiBarang != null) _row('Deskripsi', pkg.deskripsiBarang!),
                    ]),
                    _section('Pengirim', [_row('Alamat', pkg.alamatPengirim), _row('No HP', pkg.noHpPengirim)]),
                    _section('Penerima', [
                      _row('Alamat', pkg.alamatTujuan), 
                      _row('No HP', pkg.noHpPenerima),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openGoogleMaps(pkg),
                          icon: const Icon(Icons.directions),
                          label: const Text('Buka Rute di Google Maps'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/packages/${pkg.packageId}/tracker'),
                        icon: const Icon(Icons.timeline),
                        label: const Text('Lihat Riwayat Tracking'),
                      ),
                    ),
                    const SizedBox(height: 24),
                      if (isOutForDelivery) ...[
                        const Text('Aksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: OutlinedButton.icon(onPressed: () => _openGoogleMaps(pkg), icon: const Icon(Icons.directions), label: const Text('Rute'))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton.icon(onPressed: () => _confirmUpdate(PackageStatus.delivered), icon: const Icon(Icons.check), label: const Text('Selesai'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton.icon(onPressed: () => _confirmUpdate(PackageStatus.failedDelivery, destructive: true, withNotes: true), icon: const Icon(Icons.close), label: const Text('Gagal'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger))),
                      ]),
                    ] else if (nextStatuses.isNotEmpty)
                      ...nextStatuses.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _confirmUpdate(s), child: Text('Update ke: $s'))),
                      )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (_updating) const Positioned.fill(child: ColoredBox(color: Colors.black26, child: LoadingOverlay())),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)), const SizedBox(height: 8), ...children]))),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))), Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)))]),
  );
}
