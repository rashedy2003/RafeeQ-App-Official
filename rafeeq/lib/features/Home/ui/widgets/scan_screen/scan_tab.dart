import 'dart:io';
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
      // بنشغل الكاميرا أول ما الصفحة تفتح
      create: (context) => ScanCubit()..initCamera(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ScanCubit, ScanState>(
          listener: (context, state) {
            if (state is ScanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                  Expanded(child: _buildBody(state)),
                  const SizedBox(height: 20),
                  _buildScanButton(context, state),
                  const SizedBox(height: 30), // مساحة للـ NavBar
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
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          "Point your camera at a monument",
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBody(ScanState state) {
    if (state is ScanLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
      );
    }

    if (state is CameraReady) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CameraPreview(state.controller),
          ),
        ),
      );
    }

    if (state is ScanSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorsManager.rafeeqYellow, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(File(state.imagePath), fit: BoxFit.cover, width: double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              state.result,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return const Center(child: Icon(Icons.camera_alt, color: Colors.white24, size: 80));
  }

  Widget _buildScanButton(BuildContext context, ScanState state) {
    bool isSuccess = state is ScanSuccess;
    bool isReady = state is CameraReady;

    return GestureDetector(
      onTap: () {
        if (isReady) {
          context.read<ScanCubit>().captureImage();
        } else if (isSuccess) {
          context.read<ScanCubit>().resetScan();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          color: isSuccess ? Colors.white : ColorsManager.rafeeqYellow,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isSuccess ? Colors.white : ColorsManager.rafeeqYellow).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isSuccess ? Icons.refresh_rounded : Icons.camera_alt_rounded,
          size: 35,
          color: Colors.black,
        ),
      ),
    );
  }
}