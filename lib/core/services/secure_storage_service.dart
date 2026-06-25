import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, encrypted storage for sensitive values: AI API keys, Git
/// credentials/tokens, etc. Backed by Android Keystore (EncryptedSharedPreferences)
/// on Android and Keychain on iOS via flutter_secure_storage — satisfies the
/// "Secure API key storage" / "Privacy protection" requirements.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}
