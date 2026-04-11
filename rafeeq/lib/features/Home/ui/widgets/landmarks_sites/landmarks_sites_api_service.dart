import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'landmarks_sites_model.dart';

class LandmarksSitesApiService {
  final Dio dio;

  LandmarksSitesApiService(this.dio);

  Future<List<LandmarksSitesModel>> getLandmarksSites(String cityId) async {
    // بيبعت الـ ID كـ Query Parameter باسم city زي ما الـ URL طالب
    final response = await dio.get(
      ApiConstants.sites, // تأكد إن القيمة هي "sites" في ملف الثوابت
      queryParameters: {'city': cityId},
    );

    final List data = response.data['data'];
    return data.map((e) => LandmarksSitesModel.fromJson(e)).toList();
  }
}