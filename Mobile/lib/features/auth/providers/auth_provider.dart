import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_service.dart';
import '../domain/user_model.dart';

class AuthState extends ChangeNotifier {
  String? token;
  UserModel? user;
  bool isLoading = false;
  String? error;

  bool get isAuthenticated => token != null && user != null;

  void setLoading(bool v) { isLoading = v; notifyListeners(); }
  void setError(String? e) { error = e; notifyListeners(); }

  void setAuth({required String token, required UserModel user}) {
    this.token = token;
    this.user = user;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  void clear() {
    token = null;
    user = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthState>((ref) => AuthState());

Future<void> performLogin(WidgetRef ref, String email, String password) async {
  final auth = ref.read(authProvider);
  auth.setLoading(true);
  auth.setError(null);
  try {
    final result = await ref.read(authServiceProvider).login(email, password);
    await ref.read(secureStorageProvider).writeToken(result.token);
    await ref.read(secureStorageProvider).writeEmail(email);
    auth.setAuth(token: result.token, user: result.user);
  } catch (e) {
    auth.setLoading(false);
    auth.setError(e.toString().contains('salah') ? 'Email atau password salah' : 'Gagal login. Cek koneksi Anda.');
  }
}

Future<bool> restoreSession(WidgetRef ref) async {
  final token = await ref.read(secureStorageProvider).readToken();
  if (token == null) return false;
  try {
    final user = await ref.read(authServiceProvider).me(token);
    ref.read(authProvider).setAuth(token: token, user: user);
    return true;
  } catch (_) {
    await ref.read(secureStorageProvider).deleteToken();
    return false;
  }
}

Future<void> performLogout(WidgetRef ref) async {
  try { await ref.read(authServiceProvider).logout(); } catch (_) {}
  await ref.read(secureStorageProvider).deleteToken();
  ref.read(authProvider).clear();
}
