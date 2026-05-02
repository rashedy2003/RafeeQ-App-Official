import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/api/cities_api_service.dart';
import '../data/models/city_model.dart';
import 'cities_state.dart';
import '../../../../../core/networking/error_handler.dart';

class CitiesCubit extends Cubit<CitiesState> {
  final CitiesApiService apiService;
  List<CityModel> _allCities = [];

  CitiesCubit(this.apiService) : super(CitiesInitial());

  Future<void> getCities() async {
    emit(CitiesLoading());
    try {
      final cities = await apiService.getCities();

      // الترتيب الأبجدي لضمان سهولة الوصول للمحافظات
      cities.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _allCities = cities;
      emit(CitiesSuccess(cities));
    } catch (e) {
      final errorMessage = ErrorHandler.handle(e);
      emit(CitiesError(errorMessage));
    }
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      emit(CitiesSuccess(_allCities));
    } else {
      final filtered = _allCities.where((city) {
        return city.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(CitiesSuccess(filtered));
    }
  }
}