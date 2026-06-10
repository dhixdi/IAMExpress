import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((_) => SecureStorageService());

class SecureStorageService {
  static const _tokenKey = 'jwt_token';
  static const _emailKey = 'last_email';
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> writeToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
  Future<void> writeEmail(String email) => _storage.write(key: _emailKey, value: email);
  Future<String?> readEmail() => _storage.read(key: _emailKey);
}
