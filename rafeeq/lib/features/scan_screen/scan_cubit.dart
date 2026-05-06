import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_handler.dart';
import '../../../../../core/networking/error_handler.dart';
import '../../../../../core/theming/theme.dart';
import 'scan_model.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  // Getter أساسي للـ UI
  CameraController? get getCameraController => _controller;

  Future<void> initCamera() async {
    // لو الكنترولر شغال وموجود مش لازم نعمل init من الأول
    if (_controller != null && _controller!.value.isInitialized) return;

    emit(ScanLoading());
    try {
      var status = await Permission.camera.status;
      if (status.isPermanentlyDenied) {
        emit(ScanError("Camera access is blocked. Enable it from settings."));
        return;
      }

      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (!status.isGranted) {
          emit(ScanError("Camera permission is required."));
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(ScanError("No cameras found."));
        return;
      }

      _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();

      if (!isClosed) emit(CameraReady(_controller!));
    } catch (e) {
      emit(ScanError("Failed to initialize camera."));
    }
  }

  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      final String? croppedPath = await _cropImage(image.path);
      if (croppedPath != null) await uploadImage(croppedPath);
    } catch (e) {
      emit(ScanError("Failed to capture image."));
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final String? croppedPath = await _cropImage(pickedFile.path);
        if (croppedPath != null) await uploadImage(croppedPath);
      }
    } catch (e) {
      emit(ScanError("Failed to pick image."));
    }
  }

  Future<String?> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Identify Landmark',
            toolbarColor: Colors.black,
            toolbarWidgetColor: ColorsManager.rafeeqYellow,
            activeControlsWidgetColor: ColorsManager.rafeeqYellow,
          ),
        ],
      );
      return croppedFile?.path;
    } catch (e) {
      return path;
    }
  }

  Future<void> uploadImage(String path) async {
    emit(ScanLoading());
    try {
      final dio = await ApiHandler.getDio();
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: path.split('/').last),
      });

      final response = await dio.post(ApiConstants.uploadImage, data: formData);
      final resultModel = ScanModel.fromJson(response.data);
      emit(ScanSuccess(path, resultModel));
    } catch (e) {
      // هنا بنبعت الايرور بس الكنترولر بيفضل موجود في الـ memory
      final String errorMessage = ErrorHandler.handle(e);
      emit(ScanError(errorMessage));
    }
  }

  Future<void> disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  Future<void> close() async {
    await disposeCamera();
    return super.close();
  }
}







/*

2026/22/4
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_handler.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  Future<void> initCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    emit(ScanLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(ScanError("No cameras found"));
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!isClosed) emit(CameraReady(_controller!));
    } catch (e) {
      emit(ScanError("Failed to start camera: $e"));
    }
  }

  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      await _uploadImage(image.path);
    } catch (e) {
      emit(ScanError("Capture failed"));
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _uploadImage(pickedFile.path);
      }
    } catch (e) {
      emit(ScanError("Gallery access failed"));
    }
  }

  Future<void> _uploadImage(String path) async {
    emit(ScanLoading());
    try {
      final dio = await ApiHandler.getDio();
      String fileName = path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: fileName),
      });

      final response = await dio.post(
        ApiConstants.uploadImage, // scanner/scan-image
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // فك تشفير الـ Object لاستخراج الاسم فقط للفرونت إند حالياً
        String resultText = "Landmark Detected";

        if (response.data is Map) {
          // استخراج الـ name من الـ Response
          resultText = response.data['name'] ?? "Unknown Landmark";
        } else {
          resultText = response.data.toString();
        }

        emit(ScanSuccess(path, resultText));
      } else {
        emit(ScanError("Error: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String message = "Connection error";
      if (e.response != null) message = "Server error: ${e.response?.statusCode}";
      emit(ScanError(message));
    } catch (e) {
      emit(ScanError("Unexpected error occurred"));
    }
  }

  Future<void> resetScan() async {
    await initCamera();
  }

  @override
  Future<void> close() async {
    await _controller?.dispose();
    super.close();
  }
}


*/










/*import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_handler.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  Future<void> initCamera() async {
    // إغلاق أي كنترولر قديم لتجنب تسريب الذاكرة
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    emit(ScanLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(ScanError("لم يتم العثور على كاميرا في الجهاز"));
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high, // High أفضل للأداء من Max في معظم الأجهزة
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (!isClosed) emit(CameraReady(_controller!));
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            emit(ScanError("تم رفض الوصول للكاميرا. يرجى تفعيلها من الإعدادات."));
            break;
          default:
            emit(ScanError("خطأ في الكاميرا: ${e.description}"));
            break;
        }
      } else {
        emit(ScanError("فشل في تشغيل الكاميرا: $e"));
      }
    }
  }

  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      await _uploadImage(image.path);
    } catch (e) {
      emit(ScanError("فشل التقاط الصورة"));
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _uploadImage(pickedFile.path);
      }
    } catch (e) {
      emit(ScanError("فشل اختيار صورة من الاستوديو"));
    }
  }

  Future<void> _uploadImage(String path) async {
    emit(ScanLoading());
    try {
      final dio = await ApiHandler.getDio();
      String fileName = path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: fileName),
      });

      final response = await dio.post(ApiConstants.uploadImage, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String resultText = response.data is Map
            ? (response.data['result'] ?? "تم التعرف على المعلم بنجاح!")
            : response.data.toString();
        emit(ScanSuccess(path, resultText));
      } else {
        emit(ScanError("خطأ من السيرفر: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String message = "خطأ في الاتصال";
      if (e.type == DioExceptionType.connectionTimeout) message = "السيرفر بطيء جداً";
      if (e.response != null) message = "خطأ سيرفر: ${e.response?.data}";
      emit(ScanError(message));
    } catch (e) {
      emit(ScanError("حدث خطأ غير متوقع: $e"));
    }
  }

  Future<void> resetScan() async {
    await initCamera();
  }

  @override
  Future<void> close() async {
    await _controller?.dispose();
    super.close();
  }
}*/