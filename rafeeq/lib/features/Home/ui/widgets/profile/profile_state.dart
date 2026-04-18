import 'ProfileModel.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileSuccess extends ProfileState {
  final ProfileModel user; // استخدام الموديل هنا
  ProfileSuccess(this.user);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}