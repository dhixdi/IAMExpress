import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/dashboard_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService(ref.watch(dioClientProvider)));

class DashboardService {
  final Dio _dio;
  const DashboardService(this._dio);

  Future<DashboardModel> get() async {
    final res = await _dio.get('/dashboard');
    return DashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
