import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/pagination_meta.dart';
import '../domain/user_model.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService(ref.watch(dioClientProvider)));

class UserService {
  final Dio _dio;
  const UserService(this._dio);

  Future<({List<UserModel> users, PaginationMeta meta})> getAll({
    int page = 1,
    int perPage = 10,
    String? q,
    String? role,
    int? warehouseId,
  }) async {
    final res = await _dio.get('/users', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (q != null && q.isNotEmpty) 'q': q,
      if (role != null && role.isNotEmpty) 'role': role,
      if (warehouseId != null) 'warehouse_id': warehouseId,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      users: (data['users'] as List).cast<Map<String, dynamic>>().map(UserModel.fromJson).toList(),
      meta: PaginationMeta.fromJson(res.data['meta'] as Map<String, dynamic>),
    );
  }

  Future<UserModel> getById(int id) async {
    final res = await _dio.get('/users/$id');
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> create({
    required String email,
    required String password,
    required String nama,
    required String role,
    int? warehouseId,
  }) async {
    final res = await _dio.post('/users', data: {
      'email': email,
      'password': password,
      'nama': nama,
      'role': role,
      if (warehouseId != null) 'warehouse_id': warehouseId,
    });
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> update(int id, {String? nama}) async {
    final res = await _dio.put('/users/$id', data: {
      if (nama != null) 'nama': nama,
    });
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/users/$id');
  }

  Future<UserModel> changeRole(int id, String role) async {
    final res = await _dio.patch('/users/$id/role', data: {
      'role': role,
    });
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
