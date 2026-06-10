import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/error_view.dart';
import '../domain/currency_rate_model.dart';
import '../providers/currency_provider.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});
  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  String _from = 'IDR';
  String _to = 'USD';
  final _amountCtrl = TextEditingController(text: '100000');

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(currencyRatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Mata Uang')),
      body: ratesAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(currencyRatesProvider)),
        data: (rates) {
          final amount = double.tryParse(_amountCtrl.text) ?? 0;
          final result = rates.convert(amount: amount, from: _from, to: _to);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(value: _from, decoration: const InputDecoration(labelText: 'Dari'), items: supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _from = v!))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: IconButton(icon: const Icon(Icons.swap_horiz, color: AppColors.primary), onPressed: () => setState(() { final t = _from; _from = _to; _to = t; }))),
                  Expanded(child: DropdownButtonFormField<String>(value: _to, decoration: const InputDecoration(labelText: 'Ke'), items: supportedCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _to = v!))),
                ]),
                const SizedBox(height: 16),
                TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal'), onChanged: (_) => setState(() {})),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)),
                  child: Text('${currencySymbols[_to]} ${result.toStringAsFixed(_to == 'JPY' ? 0 : 2)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]))),
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Kurs Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...supportedCurrencies.where((c) => c != 'IDR').map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('1 IDR = ', style: TextStyle(color: Colors.grey[600])),
                    Text('${rates.rates[c]?.toStringAsFixed(6) ?? '-'} $c', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]),
                )),
              ]))),
              const SizedBox(height: 8),
              Text('Diperbarui: ${rates.lastUpdate.toString().substring(0, 16)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          );
        },
      ),
    );
  }
}
