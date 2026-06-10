import 'package:flutter/foundation.dart';

class AppConstants {
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1'; // Magic IP untuk Android Emulator
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }
  static const String exchangeRateApiKey = String.fromEnvironment(
    'EXCHANGERATE_API_KEY',
    defaultValue: '',
  );
  static const String appName = 'IAMExpress';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String exchangeRateBaseUrl = 'https://open.er-api.com/v6';
}
