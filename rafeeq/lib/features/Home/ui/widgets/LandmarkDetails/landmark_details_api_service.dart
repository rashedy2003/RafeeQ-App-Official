import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'Top_attractions/attraction_details_model.dart';
import 'Top_attractions/attractions_model.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsApiService {
  final Dio dio;
  LandmarkDetailsApiService(this.dio);

  Future<LandmarkDetailsModel> getLandmarkDetails(String siteId, {CancelToken? cancelToken}) async {
    // الـ Dio الممرر هنا هو الـ Global Dio اللي فيه الـ Interceptors
    final response = await dio.get("${ApiConstants.sites}/$siteId", cancelToken: cancelToken);
    return LandmarkDetailsModel.fromJson(response.data);
  }

  Future<List<AttractionModel>> getTopAttractions(String siteId, int page, {CancelToken? cancelToken}) async {
    final response = await dio.get(
      "attractions/site/$siteId",
      queryParameters: {'pageNumber': page, 'pageSize': 20},
      cancelToken: cancelToken,
    );
    final List data = response.data['data'];
    return data.map((json) => AttractionModel.fromJson(json)).toList();
  }

  Future<AttractionDetailsModel> getAttractionDetails(String attrId, {CancelToken? cancelToken}) async {
    final response = await dio.get("attractions/$attrId", cancelToken: cancelToken);
    return AttractionDetailsModel.fromJson(response.data);
  }
}