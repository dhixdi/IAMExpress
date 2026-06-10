import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/currency_service.dart';
import '../domain/currency_rate_model.dart';

final currencyRatesProvider = FutureProvider.autoDispose<CurrencyRateModel>((ref) {
  return ref.watch(currencyServiceProvider).getRates();
});
