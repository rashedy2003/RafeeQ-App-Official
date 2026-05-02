import '../../../../core/networking/api_handler.dart';

class HomeApiService {
  // الميثود القديمة لجلب بيانات الهوم
  Future<Map<String, dynamic>> getHomeData(double? lat, double? long) async {
    final dio = await ApiHandler.getDio();
    final response = await dio.get(
      "home",
      queryParameters: lat != null ? {'latitude': lat, 'longitude': long} : null,
    );
    return response.data;
  }

  // ✅ الميثود الجديدة للبحث في المواقع السياحية
  Future<Map<String, dynamic>> searchSites(String query) async {
    final dio = await ApiHandler.getDio();
    final response = await dio.get(
      "sites", // Endpoint من الـ API Reference اللي بعته
      queryParameters: {'searchTerm': query},
    );
    return response.data;
  }
}