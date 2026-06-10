const supportedCurrencies = ['IDR', 'USD', 'EUR', 'SGD', 'JPY'];
const currencyNames = {'IDR': 'Rupiah Indonesia', 'USD': 'Dolar Amerika', 'EUR': 'Euro', 'SGD': 'Dolar Singapura', 'JPY': 'Yen Jepang'};
const currencySymbols = {'IDR': 'Rp', 'USD': '\$', 'EUR': '€', 'SGD': 'S\$', 'JPY': '¥'};

class CurrencyRateModel {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime lastUpdate;

  const CurrencyRateModel({required this.baseCode, required this.rates, required this.lastUpdate});

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['conversion_rates'] as Map<String, dynamic>;
    return CurrencyRateModel(
      baseCode: json['base_code'] as String,
      rates: rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
      lastUpdate: DateTime.tryParse(json['time_last_update_utc'] as String? ?? '') ?? DateTime.now(),
    );
  }

  double convert({required double amount, required String from, required String to}) {
    if (from == to) return amount;
    if (from == baseCode) return amount * (rates[to] ?? 1);
    final toBase = amount / (rates[from] ?? 1);
    if (to == baseCode) return toBase;
    return toBase * (rates[to] ?? 1);
  }
}
