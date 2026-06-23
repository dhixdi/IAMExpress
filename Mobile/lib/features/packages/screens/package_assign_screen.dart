import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/package_service.dart';
import '../providers/package_detail_provider.dart';

final _usersByRoleProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, role) async {
  final dio = ref.watch(dioClientProvider);
  final res = await dio.get('/users', queryParameters: {'role': role, 'per_page': 100});
  final data = res.data['data'] as Map<String, dynamic>;
  return (data['users'] as List).cast<Map<String, dynamic>>();
});

final _warehouseDropdownProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final res = await dio.get('/warehouses', queryParameters: {'per_page': 100});
  final data = res.data['data'] as Map<String, dynamic>;
  return (data['warehouses'] as List).cast<Map<String, dynamic>>();
});

class PackageAssignScreen extends ConsumerStatefulWidget {
  final int packageId;
  const PackageAssignScreen({super.key, required this.packageId});

  @override
  ConsumerState<PackageAssignScreen> createState() => _PackageAssignScreenState();
}

class _PackageAssignScreenState extends ConsumerState<PackageAssignScreen> {
  bool _isLoading = false;
  int? _selectedLinehaulId;
  int? _selectedDestWarehouseId;
  int? _selectedCourierId;

  Future<void> _assign(String type, int? userId, {int? destWarehouseId}) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih user terlebih dahulu'), backgroundColor: AppColors.warning));
      return;
    }
    if (type == 'linehaul' && destWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih gudang tujuan'), backgroundColor: AppColors.warning));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(packageServiceProvider).assignPackage(
        widget.packageId,
        userId: userId,
        type: type,
        destinationWarehouseId: destWarehouseId,
      );
      ref.invalidate(packageDetailProvider(widget.packageId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket berhasil ditugaskan'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkgAsync = ref.watch(packageDetailProvider(widget.packageId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tugaskan Paket')),
      body: pkgAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(packageDetailProvider(widget.packageId))),
        data: (pkg) {
          final isAtDestination = pkg.currentWarehouseId == pkg.destinationWarehouseId && pkg.destinationWarehouseId != null;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.resi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Status: ${pkg.currentStatus}'),
                            Text('Posisi: ${pkg.currentWarehouseName ?? "Belum di gudang"}'),
                            if (pkg.destinationWarehouseName != null)
                              Text('Tujuan: ${pkg.destinationWarehouseName}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Assign Linehaul (Antar Gudang)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ref.watch(_usersByRoleProvider('LINEHAUL')).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                              data: (users) => DropdownButtonFormField<int>(
                                value: _selectedLinehaulId,
                                decoration: const InputDecoration(labelText: 'Pilih Linehaul'),
                                items: [
                                  const DropdownMenuItem<int>(value: null, child: Text('Pilih Driver')),
                                  ...users.map((u) => DropdownMenuItem<int>(
                                    value: u['user_id'] as int,
                                    child: Text('${u['nama']} (${u['email']})'),
                                  )),
                                ],
                                onChanged: (v) => setState(() => _selectedLinehaulId = v),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ref.watch(_warehouseDropdownProvider).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                              data: (warehouses) => DropdownButtonFormField<int>(
                                value: _selectedDestWarehouseId,
                                decoration: const InputDecoration(labelText: 'Gudang Tujuan'),
                                items: [
                                  const DropdownMenuItem<int>(value: null, child: Text('Pilih Gudang')),
                                  ...warehouses.map((w) => DropdownMenuItem<int>(
                                    value: w['warehouse_id'] as int,
                                    child: Text(w['nama_gudang'] as String),
                                  )),
                                ],
                                onChanged: (v) => setState(() => _selectedDestWarehouseId = v),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _assign('linehaul', _selectedLinehaulId, destWarehouseId: _selectedDestWarehouseId),
                                child: const Text('Tugaskan Linehaul'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Assign Courier (Last Mile)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (!isAtDestination)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('Kurir hanya bisa di-assign jika paket sudah berada di Gudang Tujuan.', style: TextStyle(color: AppColors.warning)),
                              ),
                            ref.watch(_usersByRoleProvider('COURIER')).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.danger)),
                              data: (users) => DropdownButtonFormField<int>(
                                value: _selectedCourierId,
                                decoration: const InputDecoration(labelText: 'Pilih Kurir'),
                                items: [
                                  const DropdownMenuItem<int>(value: null, child: Text('Pilih Kurir')),
                                  ...users.map((u) => DropdownMenuItem<int>(
                                    value: u['user_id'] as int,
                                    child: Text('${u['nama']} (${u['email']})'),
                                  )),
                                ],
                                onChanged: isAtDestination ? (v) => setState(() => _selectedCourierId = v) : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isAtDestination ? () => _assign('courier', _selectedCourierId) : null,
                                child: const Text('Tugaskan Courier'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) const Positioned.fill(child: ColoredBox(color: Colors.black26, child: LoadingOverlay())),
            ],
          );
        },
      ),
    );
  }
}
