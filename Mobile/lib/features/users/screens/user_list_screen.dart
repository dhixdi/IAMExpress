import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../data/user_service.dart';
import '../providers/user_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  final List<String?> _tabFilters = [null, 'SUPER_ADMIN', 'WAREHOUSE_ADMIN', 'LINEHAUL', 'COURIER'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final f in _tabFilters) {
        ref.read(userListProvider(f).notifier).fetchInitial();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final filter = _tabFilters[_tabCtrl.index];
      ref.read(userListProvider(filter).notifier).fetchInitial(query: q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Super Admin'),
            Tab(text: 'WH Admin'),
            Tab(text: 'Linehaul'),
            Tab(text: 'Courier'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/users/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _tabFilters.map((filter) => _UserTab(roleFilter: filter)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTab extends ConsumerStatefulWidget {
  final String? roleFilter;
  const _UserTab({this.roleFilter});

  @override
  ConsumerState<_UserTab> createState() => _UserTabState();
}

class _UserTabState extends ConsumerState<_UserTab> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(userListProvider(widget.roleFilter).notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showOptions(BuildContext context, int userId, String nama) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit User'),
              onTap: () {
                context.pop();
                context.go('/users/$userId/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.danger),
              title: const Text('Hapus User', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                context.pop();
                _confirmDelete(userId, nama);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int userId, String nama) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ConfirmBottomSheet(
        title: 'Hapus User',
        message: 'Yakin ingin menghapus $nama? Tindakan ini tidak dapat dibatalkan.',
        confirmLabel: 'Ya, Hapus',
        isDestructive: true,
        onConfirm: () async {
          try {
            await ref.read(userServiceProvider).delete(userId);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil dihapus'), backgroundColor: AppColors.success));
            ref.read(userListProvider(widget.roleFilter).notifier).refresh();
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider(widget.roleFilter));

    if (state.isLoading && state.users.isEmpty) return const LoadingOverlay();
    if (state.error != null && state.users.isEmpty) return Center(child: Text(state.error!));
    if (state.users.isEmpty) return const Center(child: Text('Tidak ada user'));

    return RefreshIndicator(
      onRefresh: () => ref.read(userListProvider(widget.roleFilter).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.users.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final user = state.users[i];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(user.role, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              trailing: Text(user.warehouseName ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              onTap: () => _showOptions(context, user.userId, user.nama),
            ),
          );
        },
      ),
    );
  }
}
