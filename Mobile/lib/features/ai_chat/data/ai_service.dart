import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService(ref.watch(dioClientProvider)));

class AiService {
  final Dio _dio;
  const AiService(this._dio);

  Future<String> chat(String message) async {
    final res = await _dio.post('/ai/chat', data: {'message': message});
    return res.data['data']['reply'] as String;
  }
}
