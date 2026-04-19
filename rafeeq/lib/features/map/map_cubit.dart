import 'package:Rafeeq/features/map/site_marker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'map_state.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_handler.dart'; // تأكد من المسار الصح

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  Future<void> getNearbyMarkers({required double lat, required double lng}) async {
    emit(MapLoading());
    try {
      // ✅ استخدام الـ Dio اللي متظبط فيه الـ Interceptors والتوكن
      final dio = await ApiHandler.getDio();

      final response = await dio.get(
        ApiConstants.places, // بما إن الـ BaseUrl موجود في الـ Handler
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
        },
      );

      debugPrint("SUCCESS: Server returned ${response.data.length} places.");

      if (response.statusCode == 200 && response.data != null) {
        List data = response.data;
        List<PlaceMarkerModel> markers = data
            .map((placeJson) => PlaceMarkerModel.fromJson(placeJson))
            .where((m) => m.id != 'error')
            .toList();

        emit(MapSuccess(markers: markers));
      }
    } on DioException catch (e) {
      // التعامل مع الـ 401 لو التوكن خلصت صلاحيته
      if (e.response?.statusCode == 401) {
        debugPrint("401 Unauthorized: التوكن مش شغال");
        emit(MapError(message: "Session expired, please login again."));
      } else {
        debugPrint("Map API Error: ${e.message}");
        emit(MapError(message: "Failed to load markers"));
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      emit(MapError(message: "An error occurred"));
    }
  }
}