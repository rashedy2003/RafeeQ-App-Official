import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsApiService {
  final Dio dio;

  LandmarkDetailsApiService(this.dio);

  Future<LandmarkDetailsModel> getLandmarkDetails(String siteId) async {
    // بنبعت الـ ID في الـ URL مباشرة: sites/13b41607...
    final response = await dio.get("${ApiConstants.sites}/$siteId");

    // السيرفر بيرجع الـ Object مباشرة في response.data
    return LandmarkDetailsModel.fromJson(response.data);
  }
}