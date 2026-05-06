import '../../core/networking/api_handler.dart';
import '../../core/networking/api_constants.dart';
import 'TripDetails/TripDetailsModel.dart';
import 'TripRequestModel.dart';

class TripsRepository {
  // ✅ ميثود الإنشاء بترجع الـ ID كـ String
  Future<String> createTrip(TripRequestModel tripData) async {
    try {
      final dio = await ApiHandler.getDio();

      // وقت انتظار كافٍ لعملية الـ AI في الباك-إند
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.post(
        ApiConstants.trips,
        data: tripData.toJson(),
      );

      // الباك-إند بيرجع الـ ID فقط كـ نص
      return response.data.toString();
    } catch (error) {
      rethrow;
    }
  }

  // ✅ ميثود جلب التفاصيل بالـ ID
  Future<TripDetailsModel> getTripDetails(String id) async {
    try {
      final dio = await ApiHandler.getDio();
      final response = await dio.get("${ApiConstants.trips}/$id");

      // هنا الـ GET بترجع الـ JSON Object كامل
      return TripDetailsModel.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }




  // جلب كل الرحلات
  Future<List<TripDetailsModel>> getAllTrips() async {
    try {
      final dio = await ApiHandler.getDio();
      final response = await dio.get(ApiConstants.trips);

      // الباك-إند بيرجع "data" جواها القائمة
      final List data = response.data['data'];
      return data.map((e) => TripDetailsModel.fromJson(e)).toList();
    } catch (error) {
      rethrow;
    }
  }

  // مسح الرحلة (HTTP DELETE)
  Future<void> deleteTrip(String id) async {
    try {
      final dio = await ApiHandler.getDio();
      await dio.delete("${ApiConstants.trips}/$id");
    } catch (error) {
      rethrow;
    }
  }






}