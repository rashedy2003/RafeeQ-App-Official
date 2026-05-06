abstract class TripsState {}

class TripsInitial extends TripsState {}
class CreateTripLoading extends TripsState {}
class CreateTripError extends TripsState {
  final String message;
  CreateTripError(this.message);
}

class CreateTripSuccess extends TripsState {
  final String tripId; // ✅ استلام الـ ID بنجاح
  CreateTripSuccess(this.tripId);
}