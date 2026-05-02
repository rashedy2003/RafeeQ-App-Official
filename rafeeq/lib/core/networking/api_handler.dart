import 'dart:developer'; // Necessary for organized logging
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
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // Disable caching to get fresh data
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );

      // 1. Existing Interceptor for Auth & Language
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

      // 2. Added LogInterceptor for full API transparency
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,    // Prints request data
          responseBody: true,   // Prints response data
          requestHeader: true,  // Prints headers (useful to check Token/Lang)
          logPrint: (object) {
            // Using log with a specific name makes it easy to filter in VS Code/Android Studio
            log(object.toString(), name: 'RafeeQ_API');
          },
        ),
      );
    }
    return _dio!;
  }
}