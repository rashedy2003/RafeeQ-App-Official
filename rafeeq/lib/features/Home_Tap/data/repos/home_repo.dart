import '../api/home_tap_api_service.dart';
import '../models/home_response.dart';

class HomeRepo {
  final HomeApiService _apiService;
  HomeRepo(this._apiService);

  Future<HomeResponse> getHomeData(double? lat, double? long) async {
    final data = await _apiService.getHomeData(lat, long);
    return HomeResponse.fromJson(data);
  }

  // ✅ جلب نتائج البحث وتحويلها لموديل (بافتراض إننا هنستخدم الـ data list)
  Future<List<dynamic>> searchSites(String query) async {
    final response = await _apiService.searchSites(query);
    return response['data'] ?? [];
  }
}