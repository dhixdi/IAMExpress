import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/package_status.dart';
import '../../../core/sensors/shake_detector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/package_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/package_list_provider.dart';

class PackageListScreen extends ConsumerStatefulWidget {
  const PackageListScreen({super.key});
  @override
  ConsumerState<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends ConsumerState<PackageListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  final _shakeDetector = ShakeDetector();
  StreamSubscription? _shakeSub;
  Timer? _debounce;

  List<String?> get _tabFilters {
    final role = ref.read(authProvider).user?.role ?? '';
    if (role == 'LINEHAUL') {
      return [null, PackageStatus.assignedToLinehaul, 'Picked Up,In Transit', PackageStatus.arrivedAtWarehouse];
    }
    if (role == 'COURIER') {
      return [null, PackageStatus.assignedToCourier, PackageStatus.outForDelivery, 'Delivered,Failed Delivery'];
    }
    // SUPER_ADMIN & WAREHOUSE_ADMIN
    return [null, 'Created,Received at Warehouse', 'Assigned to Linehaul,Picked Up,In Transit,Arrived at Warehouse,Assigned to Courier,Out For Delivery', 'Delivered,Failed Delivery'];
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _shakeSub = _shakeDetector.onShake.listen((_) {
      final filter = _tabFilters[_tabCtrl.index];
      ref.read(packageListProvider(filter).notifier).refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daftar diperbarui'), duration: Duration(seconds: 1)));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final f in _tabFilters) {
        ref.read(packageListProvider(f).notifier).fetchInitial();
      }
    });
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final filter = _tabFilters[_tabCtrl.index];
      ref.read(packageListProvider(filter).notifier).fetchInitial(query: q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(authProvider).user?.role == 'SUPER_ADMIN' || ref.watch(authProvider).user?.role == 'WAREHOUSE_ADMIN' ? 'Semua Paket' : 'Paket Saya'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          tabs: const [Tab(text: 'Semua'), Tab(text: 'Di Gudang'), Tab(text: 'Diantar'), Tab(text: 'Selesai')],
        ),
      ),
      floatingActionButton: ref.watch(authProvider).user?.role == 'WAREHOUSE_ADMIN'
          ? FloatingActionButton(
              onPressed: () => context.go('/packages/create'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Cari resi atau nama penerima...', prefixIcon: Icon(Icons.search), isDense: true),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _tabFilters.map((filter) => _PackageTab(statusFilter: filter)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTab extends ConsumerStatefulWidget {
  final String? statusFilter;
  const _PackageTab({this.statusFilter});
  @override
  ConsumerState<_PackageTab> createState() => _PackageTabState();
}

class _PackageTabState extends ConsumerState<_PackageTab> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(packageListProvider(widget.statusFilter).notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageListProvider(widget.statusFilter));
    if (state.isLoading && state.packages.isEmpty) return const LoadingOverlay();
    if (state.error != null && state.packages.isEmpty) return Center(child: Text(state.error!));
    if (state.packages.isEmpty) return const Center(child: Text('Tidak ada paket'));
    return RefreshIndicator(
      onRefresh: () => ref.read(packageListProvider(widget.statusFilter).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.packages.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.packages.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final pkg = state.packages[i];
          return PackageCard(package: pkg, onTap: () => context.go('/packages/${pkg.packageId}'));
        },
      ),
    );
  }
}
