import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(dioClientProvider)));

class AuthService {
  final Dio _dio;
  const AuthService(this._dio);

  Future<({String token, UserModel user})> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<UserModel> me(String token) async {
    final res = await _dio.get('/auth/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async => _dio.post('/auth/logout');
}
