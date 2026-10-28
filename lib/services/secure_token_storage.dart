import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  final FlutterSecureStorage _storage;
  static const _claveToken = 'auth_token';

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> guardar(String token) async {
    await _storage.write(key: _claveToken, value: token);
  }

  Future<String?> leer() async {
    return await _storage.read(key: _claveToken);
  }

  Future<void> borrar() async {
    await _storage.delete(key: _claveToken);
  }
}
