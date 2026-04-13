import 'Top_attractions/attractions_model.dart';
import 'landmark_details_model.dart';

abstract class LandmarkDetailsState {}

class LandmarkDetailsInitial extends LandmarkDetailsState {}
class LandmarkDetailsLoading extends LandmarkDetailsState {}

class LandmarkDetailsSuccess extends LandmarkDetailsState {
  final LandmarkDetailsModel details;
  final List<AttractionModel> attractions;
  final bool isMoreLoading;

  LandmarkDetailsSuccess({
    required this.details,
    required this.attractions,
    this.isMoreLoading = false,
  });
}

class LandmarkDetailsError extends LandmarkDetailsState {
  final String message;
  LandmarkDetailsError(this.message);
}