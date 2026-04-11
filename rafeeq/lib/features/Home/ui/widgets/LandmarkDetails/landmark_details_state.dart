import 'landmark_details_model.dart';

abstract class LandmarkDetailsState {}

class LandmarkDetailsInitial extends LandmarkDetailsState {}
class LandmarkDetailsLoading extends LandmarkDetailsState {}
class LandmarkDetailsSuccess extends LandmarkDetailsState {
  final LandmarkDetailsModel details;
  LandmarkDetailsSuccess(this.details);
}
class LandmarkDetailsError extends LandmarkDetailsState {
  final String message;
  LandmarkDetailsError(this.message);
}