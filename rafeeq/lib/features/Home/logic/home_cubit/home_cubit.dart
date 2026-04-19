import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'home_state.dart';
import '../../../../core/networking/api_handler.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> getHomeData() async {
    emit(HomeLoading());

    bool locationEnabled = false;
    Position? position;

    try {
      position = await _determinePosition();
      locationEnabled = true;
    } catch (e) {
      locationEnabled = false;
    }

    try {
      final dio = await ApiHandler.getDio();
      final response = await dio.get(
        "home",
        queryParameters: position != null ? {
          'latitude': position.latitude,
          'longitude': position.longitude,
        } : null,
      );

      if (response.statusCode == 200) {
        emit(HomeSuccess(
          mustVisitItems: response.data['mustVisit'] ?? [],
          hiddenGemsItems: response.data['hiddenGems'] ?? [],
          nearYouItems: response.data['nearYou'] ?? [],
          sponsors: response.data['featuredDeals'] ?? [],
          isLocationEnabled: locationEnabled,
        ));
      }
    } catch (e) {
      emit(HomeError("حدث خطأ في الاتصال"));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Disabled';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Denied';
    }
    return await Geolocator.getCurrentPosition();
  }
}