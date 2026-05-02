

// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geolocator/geolocator.dart';
// import '../data/repos/home_repo.dart';
// import 'home_state.dart';
// import 'location_service.dart';
//
// class HomeCubit extends Cubit<HomeState> {
//   final HomeRepo _homeRepo;
//
//   HomeCubit(this._homeRepo) : super(HomeInitial());
//
//   Future<void> getHomeData() async {
//     emit(HomeLoading());
//
//     bool locationEnabled = false;
//     Position? position;
//
//     try {
//       // نستخدم الخدمة الجديدة
//       position = await LocationService.determinePosition();
//       locationEnabled = true;
//       log('📍 [GPS SUCCESS] Position acquired successfully');
//     } catch (e) {
//       locationEnabled = false;
//       log('📡 [GPS WARNING] Status: $e');
//     }
//
//     try {
//       final homeData = await _homeRepo.getHomeData(
//           position?.latitude,
//           position?.longitude
//       );
//
//       emit(HomeSuccess(
//         mustVisitItems: homeData.mustVisit,
//         hiddenGemsItems: homeData.hiddenGems,
//         nearYouItems: homeData.nearYou,
//         sponsors: homeData.featuredDeals,
//         isLocationEnabled: locationEnabled,
//       ));
//
//     } on DioException catch (e) {
//       log('🚨 [HOME API ERROR] Status : ${e.response?.statusCode}');
//       emit(HomeError(_mapDioErrorToMessage(e)));
//     } catch (e) {
//       log('⚠️ [UNEXPECTED CRASH] $e');
//       emit(HomeError("error_unexpected"));
//     }
//   }
//
//   /// هذه الميثود يتم استدعاؤها من زرار الـ "Enable" في الـ UI
//   Future<void> handleLocationRequest() async {
//     try {
//       // بنحاول نجيب الموقع، لو وافق هيعمل Refresh للداتا علطول
//       await LocationService.determinePosition();
//       await getHomeData();
//     } catch (e) {
//       // لو لسه الخدمة مقفولة أو رفض، بنفتح له الإعدادات
//       if (e == 'Disabled' || e == 'PermanentlyDenied') {
//         await LocationService.openLocationSettings();
//       } else {
//         // لو رفض الصلاحية الآن (Denied)، مش هنعمل حاجة أو نظهر رسالة
//         log('User denied permission');
//       }
//     }
//   }
//
//   String _mapDioErrorToMessage(DioException error) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.receiveTimeout:
//       case DioExceptionType.connectionError:
//         return "error_connection";
//       case DioExceptionType.badResponse:
//         return "error_server";
//       default:
//         return "error_unexpected";
//     }
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/networking/error_handler.dart';
import '../data/repos/home_repo.dart';
import 'home_state.dart';
import 'location_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  Timer? _debounce;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  // ✅ الكاش عشان نرجع من السيرش للهوم فوراً
  HomeSuccess? _cachedHomeData;

  HomeCubit(this._homeRepo) : super(HomeInitial()) {
    _monitorLocationStatus();
  }

  // ميزة الـ Monitor الأصلية بتاعتك
  void _monitorLocationStatus() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      log("📡 GPS Status Changed: $status");
      refreshLocationOnly();
    });
  }

  Future<void> getHomeData() async {
    // لو مفيش كاش نظهر الشيمر، لو فيه نحدث في الخلفية
    if (_cachedHomeData == null) emit(HomeLoading());

    Position? position;
    bool locationEnabled = false;

    try {
      position = await LocationService.determinePosition();
      locationEnabled = true;
    } catch (e) {
      locationEnabled = false;
    }

    try {
      final homeData = await _homeRepo.getHomeData(
          position?.latitude,
          position?.longitude
      );

      _cachedHomeData = HomeSuccess(
        mustVisitItems: homeData.mustVisit,
        hiddenGemsItems: homeData.hiddenGems,
        nearYouItems: homeData.nearYou,
        sponsors: homeData.featuredDeals,
        isLocationEnabled: locationEnabled,
      );

      emit(_cachedHomeData!);
    } catch (e) {
      emit(HomeError(ErrorHandler.handle(e)));
    }
  }

  // ✅ الـ Smart Refresh اللي بيحدث حتة اللوكيشن بس
  Future<void> refreshLocationOnly() async {
    if (state is! HomeSuccess && _cachedHomeData == null) {
      await getHomeData();
      return;
    }

    final currentState = (state is HomeSuccess) ? state as HomeSuccess : _cachedHomeData!;
    emit(currentState.copyWith(isNearYouLoading: true));

    Position? position;
    bool locationEnabled = false;

    try {
      position = await LocationService.determinePosition();
      locationEnabled = true;
    } catch (e) {
      locationEnabled = false;
    }

    try {
      final homeData = await _homeRepo.getHomeData(
          position?.latitude,
          position?.longitude
      );

      _cachedHomeData = currentState.copyWith(
        nearYouItems: homeData.nearYou,
        isLocationEnabled: locationEnabled,
        isNearYouLoading: false,
      );

      emit(_cachedHomeData!);
      log('🎯 [SMART REFRESH] Only Near You section updated');
    } catch (e) {
      emit(currentState.copyWith(isNearYouLoading: false));
    }
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.trim().isEmpty) {
      if (_cachedHomeData != null) emit(_cachedHomeData!);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      emit(HomeSearchLoading());
      try {
        final results = await _homeRepo.searchSites(query);
        emit(HomeSearchSuccess(searchResults: results));
      } catch (e) {
        emit(HomeError(ErrorHandler.handle(e)));
      }
    });
  }

  Future<void> handleLocationRequest() async {
    try {
      await LocationService.determinePosition();
      await getHomeData(); // تحديث كامل بعد الموافقة
    } catch (e) {
      if (e == 'Disabled' || e == 'PermanentlyDenied') {
        await LocationService.openLocationSettings();
      }
    }
  }

  @override
  Future<void> close() {
    _serviceStatusStream?.cancel();
    _debounce?.cancel();
    return super.close();
  }
}