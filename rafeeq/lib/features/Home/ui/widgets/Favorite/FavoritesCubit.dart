import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'FavoriteModel.dart';
import 'FavoritesApiService.dart';

abstract class FavoritesState {}
class FavoritesInitial extends FavoritesState {}
class FavoritesLoading extends FavoritesState {}
class FavoritesSuccess extends FavoritesState {
  final List<FavoriteModel> favorites;
  FavoritesSuccess(this.favorites);
}
class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesApiService _apiService;
  List<String> favIds = [];

  FavoritesCubit(this._apiService) : super(FavoritesInitial()) {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      final favs = await _apiService.getFavorites();
      favIds = favs.map((e) => e.siteId.toString()).toList();
      emit(FavoritesSuccess(List.from(favs)));
    } catch (e) {
      // في حالة الـ 401 (Unauthorized) ممكن تظهر رسالة هنا
      emit(FavoritesError("فشل تحديث المفضلات"));
    }
  }

  Future<void> toggleFavorite(String siteId) async {
    if (siteId.isEmpty) return;

    final bool isAlreadyFav = favIds.contains(siteId);

    // 1. تحديث لحظي للواجهة
    if (isAlreadyFav) {
      favIds.remove(siteId);
    } else {
      favIds.add(siteId);
    }
    _forceUpdateUI();

    try {
      if (isAlreadyFav) {
        await _apiService.removeFavorite(siteId);
      } else {
        await _apiService.addFavorite(siteId);
      }
      // 2. مزامنة مع السيرفر للتأكد من البيانات
      await fetchFavorites();
    } on DioException catch (e) {
      // 💡 معالجة الـ Already Favorite (409)
      if (e.response?.statusCode == 409) {
        if (!favIds.contains(siteId)) favIds.add(siteId);
        await fetchFavorites();
      } else {
        // لو إيرور حقيقي (زي 401) نرجع الحالة كما كانت
        await fetchFavorites();
      }
    } catch (e) {
      await fetchFavorites();
    }
  }

  void _forceUpdateUI() {
    if (state is FavoritesSuccess) {
      emit(FavoritesSuccess(List.from((state as FavoritesSuccess).favorites)));
    } else {
      emit(FavoritesSuccess([]));
    }
  }
}