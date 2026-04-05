abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<Map<String, dynamic>> mustVisitItems;
  final List<Map<String, dynamic>> hiddenGemsItems;

  HomeSuccess(this.mustVisitItems, this.hiddenGemsItems);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}