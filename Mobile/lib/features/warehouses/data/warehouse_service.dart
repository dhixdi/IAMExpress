import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/pagination_meta.dart';
import '../domain/warehouse_model.dart';

final warehouseServiceProvider = Provider<WarehouseService>((ref) => WarehouseService(ref.watch(dioClientProvider)));

class WarehouseService {
  final Dio _dio;
  const WarehouseService(this._dio);

  Future<({List<WarehouseModel> warehouses, PaginationMeta meta})> getAll({
    int page = 1,
    int perPage = 10,
    String? q,
  }) async {
    final res = await _dio.get('/warehouses', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (q != null && q.isNotEmpty) 'q': q,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      warehouses: (data['warehouses'] as List).cast<Map<String, dynamic>>().map(WarehouseModel.fromJson).toList(),
      meta: PaginationMeta.fromJson(res.data['meta'] as Map<String, dynamic>),
    );
  }

  Future<List<WarehouseModel>> getAllSimple() async {
    final res = await _dio.get('/warehouses', queryParameters: {
      'per_page': 100,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['warehouses'] as List).cast<Map<String, dynamic>>().map(WarehouseModel.fromJson).toList();
  }

  Future<WarehouseModel> getById(int id) async {
    final res = await _dio.get('/warehouses/$id');
    return WarehouseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<WarehouseModel> create({
    required String namaGudang,
    required String alamat,
  }) async {
    final res = await _dio.post('/warehouses', data: {
      'nama_gudang': namaGudang,
      'alamat': alamat,
    });
    return WarehouseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<WarehouseModel> update(int id, {
    String? namaGudang,
    String? alamat,
  }) async {
    final res = await _dio.put('/warehouses/$id', data: {
      if (namaGudang != null) 'nama_gudang': namaGudang,
      if (alamat != null) 'alamat': alamat,
    });
    return WarehouseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/warehouses/$id');
  }
}
