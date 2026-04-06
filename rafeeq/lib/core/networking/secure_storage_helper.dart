import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'user_token';

  // حفظ التوكن المفرد
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // قراءة التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // مسح البيانات تماماً عند الـ Logout
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}