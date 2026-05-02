import 'dart:developer';
import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    String message = "error_unexpected";

    log("---------------------------------------------------------");
    log("🚨 [RafeeQ ERROR LOG]");

    if (error is DioException) {
      log("📂 Endpoint: ${error.requestOptions.path}");
      log("📩 Status Code: ${error.response?.statusCode}");
      log("📝 Full Server Response: ${error.response?.data}");

      if (error.response?.data != null && error.response?.data is Map) {
        final serverMessage = error.response?.data['message'] ?? error.response?.data['error'];
        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          log("✅ Using Server Translated Message: $serverMessage");
          return serverMessage.toString();
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          message = "error_connection";
          break;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
            message = "error_server";
          }
          break;
        default:
          message = "error_unexpected";
      }
    }
    // إضافة معالجة أخطاء اللوكيشن هنا لخدمة الـ Home
    else if (error.toString().contains('Disabled') || error.toString().contains('Denied')) {
      log("📍 GPS Error Caught: $error");
      message = "error_gps_disabled";
    }
    else {
      log("❌ Non-Dio Error: $error");
    }

    log("---------------------------------------------------------");
    return message;
  }
}