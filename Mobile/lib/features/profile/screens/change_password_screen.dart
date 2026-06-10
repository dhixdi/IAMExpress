import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/user_service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(userServiceProvider).changePassword(_oldCtrl.text, _newCtrl.text);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: AppColors.success)); context.pop(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(controller: _oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Lama'), validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru'), validator: (v) { if (v == null || v.isEmpty) return 'Wajib diisi'; if (v.length < 6) return 'Minimal 6 karakter'; return null; }),
          const SizedBox(height: 16),
          TextFormField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'), validator: (v) { if (v != _newCtrl.text) return 'Password tidak cocok'; return null; }),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan')),
        ])),
      ),
    );
  }
}
