import 'package:Rafeeq/features/Home/ui/widgets/profile/profile_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ProfileModel.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileApiService _apiService = ProfileApiService();

  ProfileCubit() : super(ProfileInitial());

  Future<void> getProfileData() async {
    emit(ProfileLoading());
    try {
      final ProfileModel userModel = await _apiService.getProfileData();
      emit(ProfileSuccess(userModel));
    } catch (e) {
      emit(ProfileError("Failed to load profile data"));
    }
  }

  Future<void> updateProfileData({
    required String firstName,
    required String lastName,
    required String nationality,
  }) async {
    try {
      // 1. تنفيذ عملية التعديل
      await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        nationality: nationality,
      );

      // 2. ✅ سحب البيانات مجدداً فوراً لتحديث الواجهة (بفضل الـ Timestamp سيتم جلب الجديد)
      await getProfileData();

    } catch (e) {
      emit(ProfileError("Update failed. Try again."));
    }
  }
}