import '../models/login_api_service.dart';
import '../models/login_request_body.dart';
import '../models/login_response.dart';

class LoginRepo {
  final LoginApiService _apiService;
  LoginRepo(this._apiService);

  // اللوجين العادي
  Future<LoginResponse> login(LoginRequestBody requestBody) async {
    return await _apiService.login(requestBody);
  }

  // ✅ نداء جوجل الجديد
  Future<LoginResponse> loginWithGoogle(LoginRequestBody requestBody) async {
    return await _apiService.loginGoogle(requestBody);
  }
}