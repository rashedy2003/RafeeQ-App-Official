import 'data/models/register_request_body.dart';
import 'register_api_service.dart';

class RegisterRepo {
  final RegisterApiService _apiService;
  RegisterRepo(this._apiService);

  Future<void> register(RegisterRequestBody requestBody) async {
    return await _apiService.register(requestBody);
  }
}