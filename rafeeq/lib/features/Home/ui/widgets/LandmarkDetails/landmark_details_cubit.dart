import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_state.dart';
import 'landmark_details_model.dart';
import 'Top_attractions/attractions_model.dart';

class LandmarkDetailsCubit extends Cubit<LandmarkDetailsState> {
  final LandmarkDetailsApiService apiService;
  final _cancelToken = CancelToken();

  LandmarkDetailsCubit(this.apiService) : super(LandmarkDetailsInitial());

  List<AttractionModel> allAttractions = [];
  int currentPage = 1;
  bool hasNext = true;
  late LandmarkDetailsModel currentDetails;

  Future<void> getInitialData(String siteId) async {
    emit(LandmarkDetailsLoading());
    try {
      currentDetails = await apiService.getLandmarkDetails(siteId, cancelToken: _cancelToken);
      allAttractions = await apiService.getTopAttractions(siteId, 1, cancelToken: _cancelToken);

      emit(LandmarkDetailsSuccess(details: currentDetails, attractions: allAttractions));
    } catch (e) {
      // الحل هنا: فحص النوع قبل استخدام isCancel
      if (e is DioException && CancelToken.isCancel(e)) return;

      emit(LandmarkDetailsError("Failed to load: ${e.toString()}"));
    }
  }

  Future<void> loadMoreAttractions(String siteId) async {
    final currentState = state;
    if (currentState is LandmarkDetailsSuccess && !currentState.isMoreLoading && hasNext) {
      emit(LandmarkDetailsSuccess(
          details: currentDetails,
          attractions: allAttractions,
          isMoreLoading: true
      ));

      try {
        currentPage++;
        final nextData = await apiService.getTopAttractions(siteId, currentPage, cancelToken: _cancelToken);

        if (nextData.isEmpty) {
          hasNext = false;
        } else {
          allAttractions.addAll(nextData);
        }

        emit(LandmarkDetailsSuccess(
            details: currentDetails,
            attractions: allAttractions,
            isMoreLoading: false
        ));
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) return;

        emit(LandmarkDetailsSuccess(
            details: currentDetails,
            attractions: allAttractions,
            isMoreLoading: false
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _cancelToken.cancel(); // إلغاء كل الريكويستات فور خروج المستخدم من الصفحة
    return super.close();
  }
}