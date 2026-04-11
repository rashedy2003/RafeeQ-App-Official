import 'package:flutter_bloc/flutter_bloc.dart';
import 'cities_api_service.dart';
import 'cities_state.dart';

class CitiesCubit extends Cubit<CitiesState> {
  final CitiesApiService apiService;

  CitiesCubit(this.apiService) : super(CitiesInitial());

  Future<void> getCities() async {
    emit(CitiesLoading());

    try {
      final cities = await apiService.getCities();
      emit(CitiesSuccess(cities));
    } catch (e) {
      emit(CitiesError(e.toString()));
    }
  }
}