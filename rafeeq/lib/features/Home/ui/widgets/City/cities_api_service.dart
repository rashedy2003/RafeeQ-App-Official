import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import 'city_model.dart';

class CitiesApiService {
  final Dio dio;

  CitiesApiService(this.dio);

  Future<List<CityModel>> getCities() async {
    // بفضل الـ Interceptor، الـ Accept-Language دلوقتى بيتبعت أوتوماتيك
    final response = await dio.get(ApiConstants.cities);

    final List data = response.data['data'];

    return data.map((e) => CityModel.fromJson(e)).toList();
  }
}