import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import '../networking/secure_storage_helper.dart';

class ApiHandler {
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
// في الـ ApiHandler
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // ✅ منع الكاش نهائياً من الـ Headers
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            String lang = prefs.getString('language_code') ?? 'en';
            options.headers['Accept-Language'] = lang;

            String? token = await SecureStorageHelper.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      );
    }
    return _dio!;
  }
}