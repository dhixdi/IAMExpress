String wmoDescription(int code) {
  if (code == 0) return 'Cerah';
  if (code <= 3) return 'Berawan sebagian';
  if (code <= 48) return 'Berkabut';
  if (code <= 67) return 'Hujan';
  if (code <= 77) return 'Salju';
  if (code <= 82) return 'Hujan deras';
  if (code <= 99) return 'Badai petir';
  return 'Tidak diketahui';
}

String wmoIcon(int code) {
  if (code == 0) return '☀';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫';
  if (code <= 67) return '🌧';
  if (code <= 77) return '❄';
  if (code <= 82) return '🌧';
  if (code <= 99) return '⛈';
  return '🌡';
}

class WeatherModel {
  final double tempCelsius;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double lat;
  final double lon;
  final int weatherCode;

  const WeatherModel({required this.tempCelsius, required this.description, required this.icon, required this.humidity, required this.windSpeed, required this.lat, required this.lon, required this.weatherCode});

  factory WeatherModel.fromJson(Map<String, dynamic> json, double lat, double lon) {
    final current = json['current'] as Map<String, dynamic>;
    final code = current['weather_code'] as int;
    return WeatherModel(
      tempCelsius: (current['temperature_2m'] as num).toDouble(),
      description: wmoDescription(code),
      icon: wmoIcon(code),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      lat: lat, lon: lon, weatherCode: code,
    );
  }
}
