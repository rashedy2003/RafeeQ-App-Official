import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'login_request_body.dart';
import 'login_response.dart';

class LoginApiService {
  final Dio _dio = Dio(BaseOptions(

    baseUrl: ApiConstants.baseUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 15),
  ));

  // الـ Constructor رجع فاضي تماماً زي زمان
  LoginApiService();

  Future<LoginResponse> login(LoginRequestBody requestBody) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: requestBody.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }
}