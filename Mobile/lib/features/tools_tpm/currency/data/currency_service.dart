import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../domain/currency_rate_model.dart';

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.exchangeRateBaseUrl, connectTimeout: const Duration(seconds: 10)));
  return CurrencyService(dio);
});

class CurrencyService {
  final Dio _dio;
  const CurrencyService(this._dio);

  Future<CurrencyRateModel> getRates() async {
    final res = await _dio.get('/latest/IDR');
    return CurrencyRateModel.fromJson(res.data as Map<String, dynamic>);
  }
}
