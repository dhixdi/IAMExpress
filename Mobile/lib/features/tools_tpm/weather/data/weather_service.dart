import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weather_model.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com/v1', connectTimeout: const Duration(seconds: 10)));
  return WeatherService(dio);
});

class WeatherService {
  final Dio _dio;
  const WeatherService(this._dio);

  Future<WeatherModel> getByCoords(double lat, double lon) async {
    final res = await _dio.get('/forecast', queryParameters: {
      'latitude': lat, 'longitude': lon,
      'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'timezone': 'Asia/Jakarta',
    });
    return WeatherModel.fromJson(res.data as Map<String, dynamic>, lat, lon);
  }
}
