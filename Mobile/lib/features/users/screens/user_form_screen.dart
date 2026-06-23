import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../data/user_service.dart';

final _warehouseDropdownProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final res = await dio.get('/warehouses', queryParameters: {'per_page': 100});
  final data = res.data['data'] as Map<String, dynamic>;
  return (data['warehouses'] as List).cast<Map<String, dynamic>>();
});

class UserFormScreen extends ConsumerStatefulWidget {
  final int? userId;
  const UserFormScreen({super.key, this.userId});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _role = 'WAREHOUSE_ADMIN';
  int? _warehouseId;

  bool get _isEdit => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
    }
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(userServiceProvider).getById(widget.userId!);
      _namaCtrl.text = user.nama;
      _emailCtrl.text = user.email;
      _role = user.role;
      _warehouseId = user.warehouseId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: AppColors.danger));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final service = ref.read(userServiceProvider);
      if (_isEdit) {
        await service.update(widget.userId!, nama: _namaCtrl.text);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil diupdate'), backgroundColor: AppColors.success));
      } else {
        await service.create(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          nama: _namaCtrl.text,
          role: _role,
          warehouseId: _warehouseId,
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil dibuat'), backgroundColor: AppColors.success));
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit User' : 'Buat User')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  if (!_isEdit) ...[
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('SUPER ADMIN')),
                        DropdownMenuItem(value: 'WAREHOUSE_ADMIN', child: Text('WAREHOUSE ADMIN')),
                        DropdownMenuItem(value: 'LINEHAUL', child: Text('LINEHAUL')),
                        DropdownMenuItem(value: 'COURIER', child: Text('COURIER')),
                      ],
                      onChanged: (v) => setState(() {
                        _role = v!;
                        if (_role == 'SUPER_ADMIN') _warehouseId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (_role != 'SUPER_ADMIN')
                      ref.watch(_warehouseDropdownProvider).when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Gagal memuat gudang: $e', style: const TextStyle(color: AppColors.danger)),
                        data: (warehouses) => DropdownButtonFormField<int?>(
                          value: _warehouseId,
                          decoration: const InputDecoration(labelText: 'Pilih Gudang'),
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('Pilih Gudang')),
                            ...warehouses.map((w) => DropdownMenuItem<int?>(
                              value: w['warehouse_id'] as int,
                              child: Text(w['nama_gudang'] as String),
                            )),
                          ],
                          validator: (v) => v == null ? 'Gudang wajib dipilih untuk role $_role' : null,
                          onChanged: (v) => setState(() => _warehouseId = v),
                        ),
                      ),
                  ] else ...[
                    TextFormField(
                      initialValue: _emailCtrl.text,
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    const Text('Untuk merubah Role, silakan gunakan fitur Change Role (jika tersedia) atau API terkait.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan User'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Positioned.fill(child: ColoredBox(color: Colors.black26, child: LoadingOverlay())),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
