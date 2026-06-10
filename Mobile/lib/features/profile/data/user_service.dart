import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/domain/user_model.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService(ref.watch(dioClientProvider)));

class UserService {
  final Dio _dio;
  const UserService(this._dio);

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.patch('/users/me/password', data: {'old_password': oldPassword, 'new_password': newPassword});
  }

  Future<UserModel> updatePhoto(String photoUrl) async {
    final res = await _dio.patch('/users/me/photo', data: {'photo_url': photoUrl});
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateBiometrics({required bool biometricsEnabled, String? biometricsType}) async {
    await _dio.patch('/users/me/biometrics', data: {
      'biometrics_enabled': biometricsEnabled,
      if (biometricsType != null) 'biometrics_type': biometricsType,
    });
  }
}
