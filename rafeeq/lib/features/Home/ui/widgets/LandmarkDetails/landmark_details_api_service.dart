import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'Top_attractions/attraction_details_model.dart';
import 'Top_attractions/attractions_model.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsApiService {
  final Dio dio;

  LandmarkDetailsApiService(this.dio);

  Future<LandmarkDetailsModel> getLandmarkDetails(String siteId) async {
    final response = await dio.get("${ApiConstants.sites}/$siteId");
    return LandmarkDetailsModel.fromJson(response.data);
  }

  // الـ Function الجديدة للـ Top Attractions مع باجينيشن

  Future<List<AttractionModel>> getTopAttractions(String siteId, int page) async {
    final response = await dio.get(
      "attractions/site/$siteId", // شلنا api/ من هنا
      queryParameters: {
        'pageNumber': page,
        'pageSize': 5,
      },
    );
    final List data = response.data['data'];
    return data.map((json) => AttractionModel.fromJson(json)).toList();
  }

  //attraction deatials

  Future<AttractionDetailsModel> getAttractionDetails(String attrId) async {
    final response = await dio.get("attractions/$attrId");
    return AttractionDetailsModel.fromJson(response.data);
  }
}