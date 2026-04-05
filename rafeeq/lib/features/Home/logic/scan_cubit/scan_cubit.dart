import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  CameraController? _controller;

  // تشغيل الكاميرا
  Future<void> initCamera() async {
    emit(ScanLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(ScanError("No cameras found"));
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await _controller!.initialize();
      emit(CameraReady(_controller!));
    } catch (e) {
      emit(ScanError("Camera failed to start: $e"));
    }
  }

  // التقاط الصورة
  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      emit(ScanLoading());

      // محاكاة لطلب الـ AI (مستقبلاً هنربط بـ API)
      await Future.delayed(const Duration(seconds: 1));

      emit(ScanSuccess(image.path, "This looks like a Great Landmark!"));
    } catch (e) {
      emit(ScanError("Failed to capture image"));
    }
  }

  // إعادة التصفير للبدء من جديد
  Future<void> resetScan() async {
    await initCamera();
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}