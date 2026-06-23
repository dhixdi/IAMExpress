import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../data/package_service.dart';
import '../providers/package_detail_provider.dart';

final _warehouseDropdownProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final res = await dio.get('/warehouses', queryParameters: {'per_page': 100});
  final data = res.data['data'] as Map<String, dynamic>;
  return (data['warehouses'] as List).cast<Map<String, dynamic>>();
});

class PackageFormScreen extends ConsumerStatefulWidget {
  final int? packageId;
  const PackageFormScreen({super.key, this.packageId});

  @override
  ConsumerState<PackageFormScreen> createState() => _PackageFormScreenState();
}

class _PackageFormScreenState extends ConsumerState<PackageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaPaketCtrl = TextEditingController();
  final _alamatPengirimCtrl = TextEditingController();
  final _noHpPengirimCtrl = TextEditingController();
  final _alamatTujuanCtrl = TextEditingController();
  final _noHpPenerimaCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  String _jenisLayanan = 'standar';
  int? _destinationWarehouseId;

  bool get _isEdit => widget.packageId != null;

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
      final pkg = await ref.read(packageServiceProvider).getById(widget.packageId!);
      _namaPaketCtrl.text = pkg.namaPaket;
      _alamatPengirimCtrl.text = pkg.alamatPengirim;
      _noHpPengirimCtrl.text = pkg.noHpPengirim;
      _alamatTujuanCtrl.text = pkg.alamatTujuan;
      _noHpPenerimaCtrl.text = pkg.noHpPenerima;
      _beratCtrl.text = pkg.berat.toString();
      _jenisLayanan = pkg.jenisLayanan;
      _deskripsiCtrl.text = pkg.deskripsiBarang ?? '';
      _destinationWarehouseId = pkg.destinationWarehouseId;
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
      final service = ref.read(packageServiceProvider);
      if (_isEdit) {
        await service.updatePackage(
          widget.packageId!,
          namaPaket: _namaPaketCtrl.text,
          deskripsiBarang: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          noHpPengirim: _noHpPengirimCtrl.text,
          noHpPenerima: _noHpPenerimaCtrl.text,
        );
        ref.invalidate(packageDetailProvider(widget.packageId!));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket berhasil diupdate'), backgroundColor: AppColors.success));
      } else {
        await service.create(
          namaPaket: _namaPaketCtrl.text,
          alamatPengirim: _alamatPengirimCtrl.text,
          alamatTujuan: _alamatTujuanCtrl.text,
          noHpPengirim: _noHpPengirimCtrl.text,
          noHpPenerima: _noHpPenerimaCtrl.text,
          berat: double.tryParse(_beratCtrl.text) ?? 1.0,
          jenisLayanan: _jenisLayanan,
          deskripsiBarang: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
          destinationWarehouseId: _destinationWarehouseId,
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket berhasil dibuat'), backgroundColor: AppColors.success));
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Paket' : 'Buat Paket')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Detail Paket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaPaketCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Paket'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deskripsiCtrl,
                    decoration: const InputDecoration(labelText: 'Deskripsi Barang (opsional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  if (!_isEdit) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _beratCtrl,
                            decoration: const InputDecoration(labelText: 'Berat (kg)'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _jenisLayanan,
                            decoration: const InputDecoration(labelText: 'Layanan'),
                            items: const [
                              DropdownMenuItem(value: 'standar', child: Text('Standar')),
                              DropdownMenuItem(value: 'express', child: Text('Express')),
                              DropdownMenuItem(value: 'kargo', child: Text('Kargo')),
                            ],
                            onChanged: (v) => setState(() => _jenisLayanan = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ref.watch(_warehouseDropdownProvider).when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Gagal memuat gudang: $e', style: const TextStyle(color: AppColors.danger)),
                      data: (warehouses) => DropdownButtonFormField<int?>(
                        value: _destinationWarehouseId,
                        decoration: const InputDecoration(labelText: 'Gudang Tujuan (Opsional)'),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Pilih Gudang Tujuan')),
                          ...warehouses.map((w) => DropdownMenuItem<int?>(
                            value: w['warehouse_id'] as int,
                            child: Text(w['nama_gudang'] as String),
                          )),
                        ],
                        onChanged: (v) => setState(() => _destinationWarehouseId = v),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text('Data Pengirim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noHpPengirimCtrl,
                    decoration: const InputDecoration(labelText: 'No HP Pengirim'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _alamatPengirimCtrl,
                    decoration: const InputDecoration(labelText: 'Alamat Pengirim'),
                    maxLines: 2,
                    enabled: !_isEdit,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  const Text('Data Penerima', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noHpPenerimaCtrl,
                    decoration: const InputDecoration(labelText: 'No HP Penerima'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _alamatTujuanCtrl,
                    decoration: const InputDecoration(labelText: 'Alamat Tujuan'),
                    maxLines: 2,
                    enabled: !_isEdit,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan Paket'),
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
    _namaPaketCtrl.dispose();
    _alamatPengirimCtrl.dispose();
    _noHpPengirimCtrl.dispose();
    _alamatTujuanCtrl.dispose();
    _noHpPenerimaCtrl.dispose();
    _beratCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }
}
