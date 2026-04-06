import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/networking/api_constants.dart';
import 'data/models/register_request_body.dart';

class RegisterApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 15),
  ));

  RegisterApiService() {
    // Interceptor to print everything in the console for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint("🌐 DIO_LOG: $obj"),
    ));
  }

  Future<void> register(RegisterRequestBody requestBody) async {
    try {
      await _dio.post(
        ApiConstants.register,
        data: requestBody.toJson(),
      );
      return;
    } on DioException catch (e) {
      debugPrint("❌ Dio Error Status: ${e.response?.statusCode}");

      if (e.response != null && e.response?.statusCode == 400) {
        final responseData = e.response?.data;

        // 1. Extract detailed validation errors (like Password requirements)
        // This handles the "errors" map sent by the .NET backend
        if (responseData['errors'] != null && responseData['errors'] is Map) {
          final Map<String, dynamic> errors = responseData['errors'];
          if (errors.isNotEmpty) {
            final firstErrorList = errors.values.first;
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              // Returns the exact server message (e.g., "Passwords must have at least one uppercase...")
              throw firstErrorList.first.toString();
            }
          }
        }

        // 2. Handle specific Error Titles or Types defined in your API
        final String errorTitle = responseData['title'] ?? "";
        final String errorType = responseData['type'] ?? "";

        if (errorType == "USER_EMAIL_EXISTS" || errorTitle == "USER_EMAIL_EXISTS") {
          throw "This email is already registered.";
        } else if (errorTitle == "VALIDATION_GENERAL") {
          throw "Invalid data. Please follow password requirements.";
        }

        // 3. Fallback to the 'detail' field from the server if available
        throw responseData['detail'] ?? "Registration failed. Please try again.";
      }

      // 4. Handle Network issues (Timeout, No Internet, etc.)
      if (e.type == DioExceptionType.connectionTimeout) {
        throw "Connection timeout. Please check your internet connection.";
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw "Server is taking too long to respond.";
      }

      throw "Server unreachable. Please check your connection or try again later.";
    } catch (e) {
      // Catch any other unexpected errors
      throw e.toString();
    }
  }
}