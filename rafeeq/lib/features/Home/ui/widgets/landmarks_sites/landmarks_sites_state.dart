import 'landmarks_sites_model.dart';

abstract class LandmarksSitesState {}

class LandmarksSitesInitial extends LandmarksSitesState {}
class LandmarksSitesLoading extends LandmarksSitesState {}
class LandmarksSitesSuccess extends LandmarksSitesState {
  final List<LandmarksSitesModel> sites;
  LandmarksSitesSuccess(this.sites);
}
class LandmarksSitesError extends LandmarksSitesState {
  final String message;
  LandmarksSitesError(this.message);
}