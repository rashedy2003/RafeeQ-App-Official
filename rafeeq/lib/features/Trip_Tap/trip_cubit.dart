import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_state.dart';
import 'TripsRepository.dart';
import 'TripRequestModel.dart';
// استيراد الـ ErrorHandler الخاص بك

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository _repository;

  TripsCubit(this._repository) : super(TripsInitial());

  Future<void> createTrip(TripRequestModel trip) async {
    emit(CreateTripLoading());
    try {
      final id = await _repository.createTrip(trip);
      emit(CreateTripSuccess(id)); // ✅ إرسال الـ ID لليوزر
    } catch (e) {
      // استخدم الـ ErrorHandler الخاص بمشروعك
      emit(CreateTripError(e.toString()));
    }
  }
}