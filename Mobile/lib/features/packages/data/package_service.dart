import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/pagination_meta.dart';
import '../domain/package_model.dart';
import '../domain/tracker_model.dart';

final packageServiceProvider = Provider<PackageService>((ref) => PackageService(ref.watch(dioClientProvider)));

class PackageService {
  final Dio _dio;
  const PackageService(this._dio);

  Future<({List<PackageModel> packages, PaginationMeta meta})> getAll({
    int page = 1, int perPage = 10,
    String? currentStatus, String? q,
    String sortBy = 'created_at', String order = 'desc',
  }) async {
    final res = await _dio.get('/packages', queryParameters: {
      'page': page, 'per_page': perPage,
      if (currentStatus != null) 'current_status': currentStatus,
      if (q != null && q.isNotEmpty) 'q': q,
      'sort_by': sortBy, 'order': order,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      packages: (data['packages'] as List).cast<Map<String, dynamic>>().map(PackageModel.fromJson).toList(),
      meta: PaginationMeta.fromJson(res.data['meta'] as Map<String, dynamic>),
    );
  }

  Future<PackageModel> getById(int id) async {
    final res = await _dio.get('/packages/$id');
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<PackageModel> updateStatus(int id, String status, {String? notes}) async {
    final res = await _dio.patch('/packages/$id/status', data: {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<PackageModel> updateStatusWithPhoto(int id, String status, File photo, {String? notes}) async {
    final formData = FormData.fromMap({
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'delivery_photo': await MultipartFile.fromFile(photo.path, filename: photo.path.split(Platform.pathSeparator).last),
    });
    final res = await _dio.patch('/packages/$id/status', data: formData);
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<PackageModel> create({
    required String namaPaket,
    required String alamatPengirim,
    required String alamatTujuan,
    required String noHpPengirim,
    required String noHpPenerima,
    required double berat,
    required String jenisLayanan,
    String? deskripsiBarang,
    int? destinationWarehouseId,
  }) async {
    final res = await _dio.post('/packages', data: {
      'nama_paket': namaPaket,
      'alamat_pengirim': alamatPengirim,
      'alamat_tujuan': alamatTujuan,
      'no_hp_pengirim': noHpPengirim,
      'no_hp_penerima': noHpPenerima,
      'berat': berat,
      'jenis_layanan': jenisLayanan,
      if (deskripsiBarang != null && deskripsiBarang.isNotEmpty) 'deskripsi_barang': deskripsiBarang,
      if (destinationWarehouseId != null) 'destination_warehouse_id': destinationWarehouseId,
    });
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<PackageModel> updatePackage(int id, {
    String? namaPaket,
    String? deskripsiBarang,
    String? noHpPengirim,
    String? noHpPenerima,
  }) async {
    final res = await _dio.put('/packages/$id', data: {
      if (namaPaket != null) 'nama_paket': namaPaket,
      if (deskripsiBarang != null) 'deskripsi_barang': deskripsiBarang,
      if (noHpPengirim != null) 'no_hp_pengirim': noHpPengirim,
      if (noHpPenerima != null) 'no_hp_penerima': noHpPenerima,
    });
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePackage(int id) async {
    await _dio.delete('/packages/$id');
  }

  Future<PackageModel> assignPackage(int id, {
    required int userId,
    required String type,
    int? destinationWarehouseId,
  }) async {
    final res = await _dio.patch('/packages/$id/assign', data: {
      'user_id': userId,
      'type': type,
      if (destinationWarehouseId != null) 'destination_warehouse_id': destinationWarehouseId,
    });
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<TrackerModel>> getTracker(int id) async {
    final res = await _dio.get('/packages/$id/tracker', queryParameters: {'sort_by': 'timestamp', 'order': 'asc'});
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['tracking'] as List).cast<Map<String, dynamic>>().map(TrackerModel.fromJson).toList();
  }
}
