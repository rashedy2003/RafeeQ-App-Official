import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/localization/locale_cubit.dart';
import '../../../../../core/theming/theme.dart';
import 'scan_cubit.dart';
import 'scan_result_screen.dart';
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
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  action: SnackBarAction(
                    label: "Retry",
                    textColor: Colors.white,
                    onPressed: () => context.read<ScanCubit>().initCamera(),
                  ),
                ),
              );
            }

            if (state is ScanSuccess) {
              final currentLang = context.read<LocaleCubit>().state.languageCode;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanResultScreen(
                    localImagePath: state.localImagePath,
                    scanResult: state.scanResult,
                    languageCode: currentLang,
                  ),
                ),
              ).then((_) {
                context.read<ScanCubit>().initCamera();
              });
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: RefreshIndicator(
                color: ColorsManager.rafeeqYellow,
                backgroundColor: Colors.black,
                onRefresh: () async {
                  await context.read<ScanCubit>().initCamera();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildHeader(),
                          const Spacer(),
                          _buildMainContent(context, state),
                          const Spacer(),
                          _buildActionButtons(context, state),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
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
        const Text(
          "Identify landmarks using AI",
          style: TextStyle(color: Colors.white70),
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

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 80),
          SizedBox(height: 10),
          Text("Pull down to refresh camera", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildFrame({required Widget child}) {
    return Center(
      child: Container(
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
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 100,
                  height: 100 * 1.3,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScanState state) {
    bool isReady = state is CameraReady;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isReady ? () => context.read<ScanCubit>().pickImage() : null,
            icon: Icon(
              Icons.photo_library_rounded,
              color: isReady ? Colors.white : Colors.white24,
              size: 30,
            ),
          ),
          GestureDetector(
            onTap: isReady ? () => context.read<ScanCubit>().captureImage() : null,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: isReady ? ColorsManager.rafeeqYellow : Colors.grey[800],
                shape: BoxShape.circle,
                boxShadow: isReady
                    ? [
                  BoxShadow(
                    color: ColorsManager.rafeeqYellow.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
                    : [],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
          const Opacity(
            opacity: 0,
            child: IconButton(onPressed: null, icon: Icon(Icons.photo_library_rounded, size: 30)),
          ),
        ],
      ),
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