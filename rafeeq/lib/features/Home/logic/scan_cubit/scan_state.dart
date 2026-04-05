import 'package:camera/camera.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class CameraReady extends ScanState {
  final CameraController controller;
  CameraReady(this.controller);
}

class ScanSuccess extends ScanState {
  final String imagePath;
  final String result;
  ScanSuccess(this.imagePath, this.result);
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}