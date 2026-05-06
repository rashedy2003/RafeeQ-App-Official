import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../core/localization/locale_cubit.dart';
import '../../../../../core/theming/theme.dart';
import 'scan_cubit.dart';
import 'scan_result_screen.dart';
import 'scan_state.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> with WidgetsBindingObserver {
  late ScanCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = ScanCubit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إعادة تشغيل الكاميرا عند العودة للتطبيق
    if (state == AppLifecycleState.resumed) _cubit.initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit..initCamera(),
      child: VisibilityDetector(
        key: const Key('scan_tab_key'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            _cubit.disposeCamera();
          } else if (info.visibleFraction == 1.0) {
            _cubit.initCamera();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocConsumer<ScanCubit, ScanState>(
            listener: (context, state) {
              if (state is ScanSuccess) {
                final lang = context.read<LocaleCubit>().state.languageCode;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanResultScreen(
                      localImagePath: state.localImagePath,
                      scanResult: state.scanResult,
                      languageCode: lang,
                    ),
                  ),
                ).then((_) => _cubit.initCamera());
              }

              // عرض الخطأ في Snackbar لو الكاميرا شغالة عشان متفصلش
              if (state is ScanError && _cubit.getCameraController != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const Spacer(),
                    _buildMainContent(state),
                    const Spacer(),
                    _buildActionButtons(state),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ScanState state) {
    final controller = _cubit.getCameraController;

    // 1. عرض الكاميرا بملء البرواز (بدون أي لودينج فوقها)
    if (controller != null && controller.value.isInitialized) {
      return _buildFrame(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize!.height,
              height: controller.value.previewSize!.width,
              child: CameraPreview(controller),
            ),
          ),
        ),
      );
    }

    // 2. حالة الخطأ أو طلب الصلاحيات (لو الكنترولر مش شغال)
    if (state is ScanError) {
      bool isPermissionError = state.message.contains("permission") ||
          state.message.contains("settings") ||
          state.message.contains("blocked");

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPermissionError ? Icons.lock_person_outlined : Icons.videocam_off_outlined,
            color: Colors.white24,
            size: 80,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.rafeeqYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (isPermissionError) {
                await openAppSettings();
              } else {
                _cubit.initCamera();
              }
            },
            child: Text(isPermissionError ? "Open Settings" : "Try Again"),
          ),
        ],
      );
    }

    // 3. لودينج مبدئي فقط عند فتح الصفحة لأول مرة
    return const Center(
      child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
    );
  }

  Widget _buildActionButtons(ScanState state) {
    bool isLoading = state is ScanLoading;
    bool isReady = _cubit.getCameraController != null &&
        _cubit.getCameraController!.value.isInitialized;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زرار الجاليري
          IconButton(
            onPressed: (isReady && !isLoading) ? () => _cubit.pickImage() : null,
            icon: Icon(
              Icons.photo_library_rounded,
              color: (isReady && !isLoading) ? Colors.white : Colors.white24,
              size: 30,
            ),
          ),
          const SizedBox(width: 40),

          // زرار الكاميرا الرئيسي (التحميل يظهر هنا فقط)
          GestureDetector(
            onTap: (isReady && !isLoading) ? () => _cubit.captureImage() : null,
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: (isReady && !isLoading) ? ColorsManager.rafeeqYellow : Colors.grey[800],
                shape: BoxShape.circle,
                boxShadow: [
                  if (isReady && !isLoading)
                    BoxShadow(
                      color: ColorsManager.rafeeqYellow.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                ],
              ),
              child: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(22),
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3.5,
                ),
              )
                  : const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 35),
            ),
          ),
          const SizedBox(width: 40),

          // أيقونة مخفية لموازنة الـ Row
          const Opacity(
            opacity: 0,
            child: Icon(Icons.photo_library_rounded, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildFrame({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: AspectRatio(
        aspectRatio: 1 / 1.3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorsManager.rafeeqYellow.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Scan Landmark",
          style: GoogleFonts.cormorantGaramond(
            color: ColorsManager.rafeeqYellow,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Identify landmarks using AI",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

/*
2023/22/4
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theming/theme.dart';
import 'scan_cubit.dart';
import 'scan_state.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanCubit()..initCamera(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ScanCubit, ScanState>(
          listener: (context, state) {
            if (state is ScanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // الجزء الخاص بالعرض (كاميرا أو صورة نجاح)
                  Expanded(child: _buildMainContent(context, state)),

                  const SizedBox(height: 20),
                  _buildActionButtons(context, state),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Scan Landmark",
          style: GoogleFonts.cormorantGaramond(
            color: ColorsManager.rafeeqYellow,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Identify landmarks using AI", style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ScanState state) {
    if (state is ScanLoading) {
      return const Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow));
    }

    if (state is CameraReady) {
      return _buildFrame(child: CameraPreview(state.controller));
    }

    if (state is ScanSuccess) {
      return Column(
        children: [
          Expanded(child: _buildFrame(child: Image.file(File(state.imagePath), fit: BoxFit.cover, width: double.infinity))),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
            child: Text(state.result, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ],
      );
    }

    return const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 80));
  }

  Widget _buildFrame({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScanState state) {
    bool isSuccess = state is ScanSuccess;
    bool isReady = state is CameraReady;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الجاليري
          isReady
              ? IconButton(
            onPressed: () => context.read<ScanCubit>().pickImage(),
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 32),
          )
              : const SizedBox(width: 48),

          // زر الأكشن الرئيسي
          GestureDetector(
            onTap: () {
              if (isReady) {
                context.read<ScanCubit>().captureImage();
              } else if (isSuccess) {
                context.read<ScanCubit>().resetScan();
              }
            },
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: isSuccess ? Colors.white : ColorsManager.rafeeqYellow,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: ColorsManager.rafeeqYellow.withOpacity(0.3), blurRadius: 15)],
              ),
              child: Icon(isSuccess ? Icons.refresh_rounded : Icons.camera_alt_rounded, size: 35, color: Colors.black),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
*/





/*import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theming/theme.dart';
import '../../../logic/scan_cubit/scan_cubit.dart';
import '../../../logic/scan_cubit/scan_state.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ScanCubit();
        // التعديل هنا: بما إن التاب مش هتتبني غير لما المستخدم يدوس عليها (بسبب الـ LazyLoadWrapper)
        // فإحنا نقدر ننادي الـ initCamera فوراً وبشكل مباشر من غير Delay يدوي.
        cubit.initCamera();
        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ScanCubit, ScanState>(
          listener: (context, state) {
            if (state is ScanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  // استخدمنا Expanded هنا عشان الكاميرا تأخد المساحة المتاحة
                  Expanded(child: _buildMainContent(context, state)),
                  const SizedBox(height: 20),
                  _buildActionButtons(context, state),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // الميثودز الباقية (Header, Frame, ActionButtons) ممتازة وزي ما هي عندك
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Scan Landmark",
          style: GoogleFonts.cormorantGaramond(
            color: ColorsManager.rafeeqYellow,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Snap a photo or upload from gallery",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ScanState state) {
    if (state is ScanLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
      );
    }

    if (state is CameraReady) {
      return _buildFrame(child: CameraPreview(state.controller));
    }

    if (state is ScanSuccess) {
      return Column(
        children: [
          Expanded(
            child: _buildFrame(
              child: Image.file(File(state.imagePath), fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 15),
          _buildResultDisplay(state.result),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 80),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.read<ScanCubit>().initCamera(),
            child: const Text("Tap to retry camera", style: TextStyle(color: ColorsManager.rafeeqYellow)),
          )
        ],
      ),
    );
  }

  Widget _buildFrame({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }

  Widget _buildResultDisplay(String result) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScanState state) {
    bool isSuccess = state is ScanSuccess;
    bool isReady = state is CameraReady;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isReady
              ? IconButton(
            onPressed: () => context.read<ScanCubit>().pickImage(),
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 30),
          )
              : const SizedBox(width: 48),
          GestureDetector(
            onTap: () {
              if (isReady) {
                context.read<ScanCubit>().captureImage();
              } else if (isSuccess) {
                context.read<ScanCubit>().resetScan();
              }
            },
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: isSuccess ? Colors.white : ColorsManager.rafeeqYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.rafeeqYellow.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(
                isSuccess ? Icons.refresh_rounded : Icons.camera_alt_rounded,
                size: 35,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}*/