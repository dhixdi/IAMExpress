import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _canBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final email = await ref.read(secureStorageProvider).readEmail();
    if (email != null) {
      final auth = LocalAuthentication();
      final can = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      setState(() { _canBiometric = can; });
    }
  }

  Future<void> _loginWithBiometrics() async {
    final auth = LocalAuthentication();
    try {
      final didAuth = await auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk ke IAMExpress',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth && mounted) {
        await restoreSession(ref);
      }
    } catch (_) {}
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    await performLogin(ref, _emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.local_shipping_rounded, size: 64, color: AppColors.accent),
                  SizedBox(height: 16),
                  Text('IAMExpress', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Linehaul & Courier App', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),
                    if (auth.error != null) Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    if (_canBiometric) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _loginWithBiometrics,
                        icon: const Icon(Icons.fingerprint, size: 24),
                        label: const Text('Masuk dengan Biometrik'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
