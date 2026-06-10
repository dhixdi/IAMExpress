import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/user_service.dart';
import '../../auth/providers/auth_provider.dart';

class BiometricSettingScreen extends ConsumerStatefulWidget {
  const BiometricSettingScreen({super.key});
  @override
  ConsumerState<BiometricSettingScreen> createState() => _BiometricSettingScreenState();
}

class _BiometricSettingScreenState extends ConsumerState<BiometricSettingScreen> {
  late bool _enabled;
  String _type = 'fingerprint';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _enabled = user?.biometricsEnabled ?? false;
    _type = user?.biometricsType ?? 'fingerprint';
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(userServiceProvider).updateBiometrics(biometricsEnabled: _enabled, biometricsType: _enabled ? _type : null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan biometrik disimpan'), backgroundColor: AppColors.success));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Biometrik')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SwitchListTile(title: const Text('Aktifkan Biometrik'), value: _enabled, activeTrackColor: AppColors.primary, onChanged: (v) => setState(() => _enabled = v)),
          if (_enabled) ...[
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Sidik Jari'),
              leading: Radio<String>(value: 'fingerprint', groupValue: _type, activeColor: AppColors.primary, onChanged: (v) => setState(() => _type = v!)),
              onTap: () => setState(() => _type = 'fingerprint'),
            ),
            ListTile(
              title: const Text('Wajah'),
              leading: Radio<String>(value: 'face', groupValue: _type, activeColor: AppColors.primary, onChanged: (v) => setState(() => _type = v!)),
              onTap: () => setState(() => _type = 'face'),
            ),
          ],
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.info_outline, color: AppColors.info), const SizedBox(width: 12), Expanded(child: Text('Validasi dilakukan di perangkat Anda. Data biometrik tidak dikirim ke server.', style: TextStyle(fontSize: 13, color: Colors.grey[600])))]))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan')),
        ]),
      ),
    );
  }
}
