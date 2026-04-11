import 'package:flutter_bloc/flutter_bloc.dart';
import 'landmarks_sites_api_service.dart';
import 'landmarks_sites_state.dart';

class LandmarksSitesCubit extends Cubit<LandmarksSitesState> {
  final LandmarksSitesApiService apiService;

  LandmarksSitesCubit(this.apiService) : super(LandmarksSitesInitial());

  Future<void> getLandmarksSites(String cityId) async {
    emit(LandmarksSitesLoading());
    try {
      final sites = await apiService.getLandmarksSites(cityId);
      emit(LandmarksSitesSuccess(sites));
    } catch (e) {
      emit(LandmarksSitesError("Error loading sites: ${e.toString()}"));
    }
  }
}