import 'package:flutter_bloc/flutter_bloc.dart';
import 'Top_attractions/attractions_model.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_state.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsCubit extends Cubit<LandmarkDetailsState> {
  final LandmarkDetailsApiService apiService;

  LandmarkDetailsCubit(this.apiService) : super(LandmarkDetailsInitial());

  List<AttractionModel> allAttractions = [];
  int currentPage = 1;
  bool hasNext = true;
  late LandmarkDetailsModel currentDetails;

  Future<void> getInitialData(String siteId) async {
    emit(LandmarkDetailsLoading());
    try {
      // بنحمل تفاصيل المكان وأول 5 أماكن مقترحة مع بعض
      currentDetails = await apiService.getLandmarkDetails(siteId);
      allAttractions = await apiService.getTopAttractions(siteId, 1);

      emit(LandmarkDetailsSuccess(
        details: currentDetails,
        attractions: allAttractions,
      ));
    } catch (e) {
      emit(LandmarkDetailsError("Failed to load: ${e.toString()}"));
    }
  }

  Future<void> loadMoreAttractions(String siteId) async {
    final currentState = state;

    // التأكد إن الحالة الحالية Success وإني مش بحمل داتا فعلياً حالياً وفي داتا باقية
    if (currentState is LandmarkDetailsSuccess && !currentState.isMoreLoading && hasNext) {

      // هنا التصحيح: بنستخدم ":" وليس "="
      emit(LandmarkDetailsSuccess(
        details: currentDetails,
        attractions: allAttractions,
        isMoreLoading: true, // تم التصحيح هنا
      ));

      try {
        currentPage++;
        final nextData = await apiService.getTopAttractions(siteId, currentPage);

        if (nextData.isEmpty) {
          hasNext = false;
        } else {
          allAttractions.addAll(nextData);
        }

        emit(LandmarkDetailsSuccess(
          details: currentDetails,
          attractions: allAttractions,
          isMoreLoading: false, // تم التصحيح هنا
        ));
      } catch (e) {
        // في حالة الخطأ بنرجع الحالة لـ false عشان يقدر يحاول تاني
        emit(LandmarkDetailsSuccess(
          details: currentDetails,
          attractions: allAttractions,
          isMoreLoading: false,
        ));
      }
    }
  }
}