class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://iamexpress-backend-254683579194.asia-southeast2.run.app/api/v1',
  );
  static const String exchangeRateApiKey = String.fromEnvironment(
    'EXCHANGERATE_API_KEY',
    defaultValue: '',
  );
  static const String appName = 'IAMExpress';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String exchangeRateBaseUrl = 'https://v6.exchangerate-api.com/v6';
}
