import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import '../models/landmarks_sites_model.dart';

class LandmarksSitesApiService {
  final Dio dio;

  LandmarksSitesApiService(this.dio);

  Future<List<LandmarksSitesModel>> getLandmarksSites({required String cityId, String? searchTerm}) async {
    final response = await dio.get(
      ApiConstants.sites,
      queryParameters: {
        'city': cityId,
        if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
      },
    );

    // التحقق من مكان الداتا في الـ Response حسب الدوكمنتيشن
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? []);

    return data.map((e) => LandmarksSitesModel.fromJson(e)).toList();
  }
}