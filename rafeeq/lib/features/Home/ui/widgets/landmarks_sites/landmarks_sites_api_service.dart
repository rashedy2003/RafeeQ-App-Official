import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'landmarks_sites_model.dart';

class LandmarksSitesApiService {
  final Dio dio;

  LandmarksSitesApiService(this.dio);

  Future<List<LandmarksSitesModel>> getLandmarksSites(String cityId) async {
    // الـ Dio اللي هنا دلوقت فيه الـ Accept-Language والـ Token بفضل الـ ApiHandler
    final response = await dio.get(
      ApiConstants.sites,
      queryParameters: {'city': cityId},
    );

    final List data = response.data['data'];
    return data.map((e) => LandmarksSitesModel.fromJson(e)).toList();
  }
}