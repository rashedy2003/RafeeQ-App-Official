abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeSearchLoading extends HomeState {}

// ✅ ضيف السطر ده هنا عشان الـ Cubit يشوفه
class HomeInitialSearch extends HomeState {}

class HomeSuccess extends HomeState {
  final List<dynamic> mustVisitItems;
  final List<dynamic> hiddenGemsItems;
  final List<dynamic> nearYouItems;
  final List<dynamic> sponsors;
  final bool isLocationEnabled;
  final bool isNearYouLoading;

  HomeSuccess({
    required this.mustVisitItems,
    required this.hiddenGemsItems,
    required this.nearYouItems,
    required this.sponsors,
    required this.isLocationEnabled,
    this.isNearYouLoading = false,
  });

  HomeSuccess copyWith({List<dynamic>? nearYouItems, bool? isLocationEnabled, bool? isNearYouLoading}) {
    return HomeSuccess(
      mustVisitItems: this.mustVisitItems,
      hiddenGemsItems: this.hiddenGemsItems,
      nearYouItems: nearYouItems ?? this.nearYouItems,
      sponsors: this.sponsors,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isNearYouLoading: isNearYouLoading ?? this.isNearYouLoading,
    );
  }
}

class HomeSearchSuccess extends HomeState {
  final List<dynamic> searchResults;
  HomeSearchSuccess({required this.searchResults});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}