import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/api/landmarks_sites_api_service.dart';
import 'landmarks_sites_state.dart';
import '../../../../../core/networking/error_handler.dart';

class LandmarksSitesCubit extends Cubit<LandmarksSitesState> {
  final LandmarksSitesApiService apiService;

  LandmarksSitesCubit(this.apiService) : super(LandmarksSitesInitial());

  Future<void> getLandmarksSites(String cityId, {String? query}) async {
    // لضمان عدم حدوث وميض (Flicker) أثناء البحث، نظهر اللودينج فقط في البداية
    if (query == null || query.isEmpty) emit(LandmarksSitesLoading());

    try {
      final sites = await apiService.getLandmarksSites(cityId: cityId, searchTerm: query);
      emit(LandmarksSitesSuccess(sites));
    } catch (e) {
      final errorKey = ErrorHandler.handle(e);
      emit(LandmarksSitesError(errorKey));
    }
  }
}