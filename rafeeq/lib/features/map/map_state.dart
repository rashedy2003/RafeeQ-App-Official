import 'package:Rafeeq/features/map/site_marker_model.dart';


abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapSuccess extends MapState {
  final List<PlaceMarkerModel> markers;
  MapSuccess({required this.markers});
}

class MapError extends MapState {
  final String message;
  MapError({required this.message});
}