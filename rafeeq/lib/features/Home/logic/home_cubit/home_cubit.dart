import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/networking/api_handler.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  // شيلنا تعريف Dio() الـ manual عشان نستخدم الـ Managed Instance
  HomeCubit() : super(HomeInitial());

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      // 1. جلب الـ Dio Instance اللي فيه الـ Interceptor بتاع اللغة والتوكن
      final dio = await ApiHandler.getDio();

      // 2. جلب الموقع الحقيقي للمستخدم
      Position position = await _determinePosition();

      print("📍 Current User Location: ${position.latitude}, ${position.longitude}");

      // 3. تنفيذ الـ Request (الهيدرز هتتضاف أوتوماتيك من الـ ApiHandler)
      final response = await dio.get(
        "home", // بما إننا حاطين الـ BaseUrl في الـ Handler بنكتب الـ endpoint بس
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        emit(HomeSuccess(
          mustVisitItems: data['mustVisit'] ?? [],
          hiddenGemsItems: data['hiddenGems'] ?? [],
          nearYouItems: data['nearYou'] ?? [],
          sponsors: data['featuredDeals'] ?? [],
        ));
      }
    } catch (e) {
      print("❌ Error: $e");
      emit(HomeError("تأكد من تفعيل الموقع والاتصال بالإنترنت"));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}