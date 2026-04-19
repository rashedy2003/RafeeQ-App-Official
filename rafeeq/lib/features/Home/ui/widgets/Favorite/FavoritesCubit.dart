import 'package:flutter_bloc/flutter_bloc.dart';
import 'FavoriteModel.dart';
import 'FavoritesApiService.dart';

// States (نفسها)
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
      // ✅ نغير الحالة لـ Loading عشان اليوزر ميبقاش شايف بيانات قديمة بلغة قديمة
      emit(FavoritesLoading());

      final favs = await _apiService.getFavorites();
      favIds = favs.map((e) => e.siteId.toString()).toList();
      emit(FavoritesSuccess(List.from(favs)));
    } catch (e) {
      emit(FavoritesError("Error updating favorites"));
    }
  }

  Future<void> toggleFavorite(String siteId) async {
    if (siteId.isEmpty) return;
    final bool isAlreadyFav = favIds.contains(siteId);

    // تحديث UI فوري
    if (isAlreadyFav) favIds.remove(siteId);
    else favIds.add(siteId);

    _forceUpdateUI();

    try {
      if (isAlreadyFav) await _apiService.removeFavorite(siteId);
      else await _apiService.addFavorite(siteId);

      // هنا مش بنعمل emit(Loading) عشان الحركة تبقى ناعمة، بس بنحدث البيانات في الخلفية
      final favs = await _apiService.getFavorites();
      favIds = favs.map((e) => e.siteId.toString()).toList();
      emit(FavoritesSuccess(List.from(favs)));
    } catch (e) {
      fetchFavorites(); // رجع الحالة زي ما كانت لو فشل
    }
  }

  void _forceUpdateUI() {
    if (state is FavoritesSuccess) {
      emit(FavoritesSuccess(List.from((state as FavoritesSuccess).favorites)));
    }
  }
}