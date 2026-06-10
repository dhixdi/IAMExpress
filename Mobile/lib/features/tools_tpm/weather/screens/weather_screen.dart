import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  String _contextualBanner(int code, double wind) {
    if (code >= 80) return '⛈ Badai — Pertimbangkan menunda pengiriman';
    if (code >= 51) return '🌧 Hujan — Hati-hati saat delivery, paket rentan basah';
    if (wind > 40) return '💨 Angin kencang — Waspada saat berkendara';
    if (code == 0) return '☀ Cuaca cerah — Kondisi ideal untuk pengiriman';
    return '⛅ Cuaca mendung — Tetap waspada saat pengiriman';
  }

  Color _bannerColor(int code) {
    if (code >= 80) return AppColors.danger;
    if (code >= 51) return AppColors.warning;
    if (code == 0) return AppColors.success;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cuaca')),
      body: weatherAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: 'Gagal memuat cuaca. Pastikan GPS aktif.', onRetry: () => ref.invalidate(weatherProvider)),
        data: (w) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight.withValues(alpha: 0.8)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(children: [
                  Text(w.locationName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Text(w.icon, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  Text(w.description, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${w.tempCelsius.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.water_drop_outlined, color: AppColors.info), const SizedBox(height: 4), Text('${w.humidity}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const Text('Kelembaban', style: TextStyle(fontSize: 12, color: AppColors.textMuted))])))),
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.air, color: AppColors.textMuted), const SizedBox(height: 4), Text('${w.windSpeed.toStringAsFixed(1)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const Text('km/h Angin', style: TextStyle(fontSize: 12, color: AppColors.textMuted))])))),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _bannerColor(w.weatherCode).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _bannerColor(w.weatherCode).withValues(alpha: 0.3))),
              child: Text(_contextualBanner(w.weatherCode, w.windSpeed), style: TextStyle(fontSize: 14, color: _bannerColor(w.weatherCode), fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            const Text('Sumber: Open-Meteo | Tidak memerlukan API key', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}
