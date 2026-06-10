import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  factory ApiException.fromDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      final msg = data is Map ? (data['message'] as String? ?? 'Terjadi kesalahan') : 'Terjadi kesalahan';
      return ApiException(statusCode: error.response!.statusCode ?? 0, message: msg);
    }
    return ApiException(statusCode: 0, message: error.message ?? 'Koneksi gagal');
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
