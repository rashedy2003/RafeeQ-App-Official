import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'FavoriteModel.dart';

class FavoritesApiService {
  final Dio _dio;
  FavoritesApiService(this._dio);

  Future<List<FavoriteModel>> getFavorites() async {
    final response = await _dio.get(ApiConstants.favorites);
    // السيرفر بيبعت لستة جوه مفتاح "data"
    return (response.data['data'] as List)
        .map((e) => FavoriteModel.fromJson(e))
        .toList();
  }

  Future<void> addFavorite(String siteId) async {
    try {
      await _dio.post(
        ApiConstants.favorites,
        // إرسال الـ Map مباشرة والـ Dio سيقوم بتحويلها لـ JSON Body
        data: {
          "siteId": siteId,
        },
      );
    } on DioException catch (e) {
      print("❌ Add Error Status Code: ${e.response?.statusCode}");
      print("❌ Add Error Data: ${e.response?.data}");
      print("❌ Full Error Info: $e");
      rethrow;
    }
  }

  Future<void> removeFavorite(String siteId) async {
    try {
      print("📡 Attempting to Delete: $siteId");

      final response = await _dio.delete(
        ApiConstants.favorites,
        // جرب نبعتها كـ Map مباشرة زي الـ Add
        data: {
          "siteId": siteId,
        },
      );

      print("✅ Deleted Successfully: ${response.data}");
    } on DioException catch (e) {
      print("❌ Delete Error Status: ${e.response?.statusCode}");
      print("❌ Delete Error Message: ${e.response?.data}");

      // 💡 لو السيرفر رجع 405 أو 400، جرب تبعتها في الـ Query String
      // لو الباك-إند قلك "ابعتها في اللينك"، استخدم السطر اللي تحت ده بدل اللي فوق:
      // await _dio.delete("${ApiConstants.favorites}?siteId=$siteId");

      rethrow;
    }
  }

}