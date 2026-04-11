import 'package:flutter_bloc/flutter_bloc.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_state.dart';

class LandmarkDetailsCubit extends Cubit<LandmarkDetailsState> {
  final LandmarkDetailsApiService apiService;

  LandmarkDetailsCubit(this.apiService) : super(LandmarkDetailsInitial());

  Future<void> getLandmarkDetails(String siteId) async {
    emit(LandmarkDetailsLoading());
    try {
      final details = await apiService.getLandmarkDetails(siteId);
      emit(LandmarkDetailsSuccess(details));
    } catch (e) {
      emit(LandmarkDetailsError("Failed to load details: ${e.toString()}"));
    }
  }
}