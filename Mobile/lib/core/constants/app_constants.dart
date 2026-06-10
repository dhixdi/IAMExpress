class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  static const String exchangeRateApiKey = String.fromEnvironment(
    'EXCHANGERATE_API_KEY',
    defaultValue: '',
  );
  static const String appName = 'IAMExpress';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String exchangeRateBaseUrl = 'https://v6.exchangerate-api.com/v6';
}
