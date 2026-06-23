import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../data/warehouse_service.dart';
import '../providers/warehouse_provider.dart';

class WarehouseListScreen extends ConsumerStatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  ConsumerState<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends ConsumerState<WarehouseListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(warehouseListProvider.notifier).fetchInitial();
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(warehouseListProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(warehouseListProvider.notifier).fetchInitial(query: q);
    });
  }

  void _showOptions(BuildContext context, int id, String nama) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Gudang'),
              onTap: () {
                context.pop();
                context.go('/warehouses/$id/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.danger),
              title: const Text('Hapus Gudang', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                context.pop();
                _confirmDelete(id, nama);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id, String nama) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ConfirmBottomSheet(
        title: 'Hapus Gudang',
        message: 'Yakin ingin menghapus $nama? Pastikan gudang ini sudah tidak memiliki paket di dalamnya. Tindakan ini tidak dapat dibatalkan.',
        confirmLabel: 'Ya, Hapus',
        isDestructive: true,
        onConfirm: () async {
          try {
            await ref.read(warehouseServiceProvider).delete(id);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gudang berhasil dihapus'), backgroundColor: AppColors.success));
            ref.read(warehouseListProvider.notifier).refresh();
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Gudang')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/warehouses/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau alamat...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: _buildList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildList(WarehouseListState state) {
    if (state.isLoading && state.warehouses.isEmpty) return const LoadingOverlay();
    if (state.error != null && state.warehouses.isEmpty) return Center(child: Text(state.error!));
    if (state.warehouses.isEmpty) return const Center(child: Text('Tidak ada gudang'));

    return RefreshIndicator(
      onRefresh: () => ref.read(warehouseListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.warehouses.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.warehouses.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final wh = state.warehouses[i];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.warehouse, color: Colors.white),
              ),
              title: Text(wh.namaGudang, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(wh.alamat, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: wh.lat != null && wh.lng != null ? const Icon(Icons.location_on, color: AppColors.success, size: 16) : null,
              onTap: () => _showOptions(context, wh.warehouseId, wh.namaGudang),
            ),
          );
        },
      ),
    );
  }
}
