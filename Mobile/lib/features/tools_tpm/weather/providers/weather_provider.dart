import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/weather_service.dart';
import '../domain/weather_model.dart';

final weatherProvider = FutureProvider.autoDispose<WeatherModel>((ref) async {
  await Geolocator.requestPermission();
  final pos = await Geolocator.getCurrentPosition();
  return ref.watch(weatherServiceProvider).getByCoords(pos.latitude, pos.longitude);
});
