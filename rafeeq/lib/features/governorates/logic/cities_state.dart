import '../data/models/city_model.dart';

abstract class CitiesState {}

class CitiesInitial extends CitiesState {}

class CitiesLoading extends CitiesState {}

class CitiesSuccess extends CitiesState {
  final List<CityModel> cities;
  CitiesSuccess(this.cities);
}

class CitiesError extends CitiesState {
  final String message; // دي هتشيل إما رسالة الباك إند أو الـ Key بتاعنا
  CitiesError(this.message);
}