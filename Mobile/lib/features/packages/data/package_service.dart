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

  Future<List<TrackerModel>> getTracker(int id) async {
    final res = await _dio.get('/packages/$id/tracker', queryParameters: {'sort_by': 'timestamp', 'order': 'asc'});
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['tracking'] as List).cast<Map<String, dynamic>>().map(TrackerModel.fromJson).toList();
  }
}
