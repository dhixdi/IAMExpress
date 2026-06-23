import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../data/warehouse_service.dart';

class WarehouseFormScreen extends ConsumerStatefulWidget {
  final int? warehouseId;
  const WarehouseFormScreen({super.key, this.warehouseId});

  @override
  ConsumerState<WarehouseFormScreen> createState() => _WarehouseFormScreenState();
}

class _WarehouseFormScreenState extends ConsumerState<WarehouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  bool get _isEdit => widget.warehouseId != null;

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
      final wh = await ref.read(warehouseServiceProvider).getById(widget.warehouseId!);
      _namaCtrl.text = wh.namaGudang;
      _alamatCtrl.text = wh.alamat;
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
      final service = ref.read(warehouseServiceProvider);
      if (_isEdit) {
        await service.update(
          widget.warehouseId!,
          namaGudang: _namaCtrl.text,
          alamat: _alamatCtrl.text,
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gudang berhasil diupdate'), backgroundColor: AppColors.success));
      } else {
        await service.create(
          namaGudang: _namaCtrl.text,
          alamat: _alamatCtrl.text,
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gudang berhasil dibuat'), backgroundColor: AppColors.success));
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Gudang' : 'Buat Gudang')),
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
                    decoration: const InputDecoration(labelText: 'Nama Gudang'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _alamatCtrl,
                    decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Info: Koordinat akan di-generate otomatis dari alamat.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan Gudang'),
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
    _alamatCtrl.dispose();
    super.dispose();
  }
}
