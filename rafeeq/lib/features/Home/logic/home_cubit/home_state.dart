abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<dynamic> mustVisitItems;
  final List<dynamic> hiddenGemsItems;
  final List<dynamic> nearYouItems;
  final List<dynamic> sponsors;

  HomeSuccess({
    required this.mustVisitItems,
    required this.hiddenGemsItems,
    required this.nearYouItems,
    required this.sponsors,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}