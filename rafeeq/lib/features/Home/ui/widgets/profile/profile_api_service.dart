

import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_handler.dart' show ApiHandler;
import 'ProfileModel.dart';

class ProfileApiService {
  // ✅ جلب البيانات مع كسر الكاش
  Future<ProfileModel> getProfileData() async {
    try {
      final dio = await ApiHandler.getDio();

      // إضافة Timestamp للـ URL لضمان جلب داتا جديدة من السيرفر
      final String urlWithTimestamp = "${ApiConstants.profile}?t=${DateTime.now().millisecondsSinceEpoch}";

      final response = await dio.get(urlWithTimestamp);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ تعديل البيانات باستخدام PUT
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String nationality,
  }) async {
    try {
      final dio = await ApiHandler.getDio();
      await dio.put(
        ApiConstants.profile,
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "nationality": nationality,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}