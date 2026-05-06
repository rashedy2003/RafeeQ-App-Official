import 'package:camera/camera.dart';
import 'scan_model.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}
class ScanLoading extends ScanState {}

class CameraReady extends ScanState {
  final CameraController controller;
  CameraReady(this.controller);
}

class ScanSuccess extends ScanState {
  final String localImagePath;
  final ScanModel scanResult;
  ScanSuccess(this.localImagePath, this.scanResult);
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}











/*

اخر حاجه من يومين النهارده 2026/22/4

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
  final String result; // سنخزن فيه الـ name المستخرج من الـ Object
  ScanSuccess(this.imagePath, this.result);
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}


*/










/*import 'package:camera/camera.dart';

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
}*/