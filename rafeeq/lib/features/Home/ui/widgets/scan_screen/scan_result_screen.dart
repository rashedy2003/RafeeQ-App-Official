import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// استبدل المسارات دي بمسارات مشروعك الحقيقية

import '../../../../../core/theming/theme.dart';
import 'scan_model.dart';

class ScanResultScreen extends StatefulWidget {
  final String localImagePath;
  final ScanModel scanResult;
  final String languageCode;

  const ScanResultScreen({
    super.key,
    required this.localImagePath,
    required this.scanResult,
    required this.languageCode,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late FlutterTts _flutterTts;
  bool isSpeaking = false;
  bool isSettingsOpen = false;
  bool isProcessing = false;
  double speechRate = 0.5;
  double pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(widget.languageCode);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() { isSpeaking = true; isProcessing = false; });
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() { isSpeaking = false; isProcessing = false; });
    });
  }

  // ميثود إضافية لضمان تنظيف الميموري 100%
  @override
  void dispose() {
    // 1. وقف الصوت فوراً
    _flutterTts.stop();

    // 2. تصفير كل الـ Handlers عشان الـ Plugin ميبعتش أي Logs للصفحة وهي مقفولة
    _flutterTts.setStartHandler(() {});
    _flutterTts.setCompletionHandler(() {});
    _flutterTts.setErrorHandler((msg) {});
    _flutterTts.setCancelHandler(() {});

    // 3. طباعة تأكيد في الـ Debug Console إن الصفحة اتمسحت
    debugPrint("Refeeq_Log: ScanResultScreen Disposed Successfully.");

    super.dispose();
  }

  // ميثود للرجوع تضمن توقف كل شيء قبل إغلاق الصفحة
  Future<bool> _stopAndPop() async {
    await _flutterTts.stop();
    return true;
  }

  void _updateConfig(double? rate, double? p) async {
    setState(() {
      if (rate != null) speechRate = rate;
      if (p != null) pitch = p;
      isProcessing = true;
    });

    if (isSpeaking) {
      await _flutterTts.stop();
      _handleSpeech();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _handleSpeech() async {
    if (isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => isSpeaking = false);
    } else {
      if (mounted) setState(() => isProcessing = true);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.speak(widget.scanResult.description ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // استخدام PopScope لضمان التنظيف لو اليوزر رجع بزرار الموبايل
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _stopAndPop(),
      child: Scaffold(
        backgroundColor: ColorsManager.black,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(size),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.03),
                    _buildTitleSection(),
                    SizedBox(height: size.height * 0.025),
                    _buildModernAudioBox(),
                    SizedBox(height: size.height * 0.04),
                    _buildAnimatedDescriptionTitle(),
                    SizedBox(height: size.height * 0.015),
                    _buildDescriptionBody(),
                    SizedBox(height: size.height * 0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LANDMARK",
          style: TextStyles.font12YellowSemiBold.copyWith(letterSpacing: 2),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        const SizedBox(height: 5),
        Text(
          widget.scanResult.name?.toUpperCase() ?? "UNKNOWN LANDMARK",
          style: TextStyles.font26MontserratBlack.copyWith(
            color: ColorsManager.rafeeqYellow,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildAnimatedDescriptionTitle() {
    const String titleText = 'DESCRIPTION';
    return Text(
      titleText,
      style: GoogleFonts.cinzel(
        color: const Color(0xFFF1E4C1),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.0,
      ),
    ).animate(
      onPlay: (controller) => controller.forward(),
    ).custom(
      duration: 1500.ms,
      builder: (context, value, child) {
        int charactersToShow = (value * titleText.length).floor();
        return Text(
          titleText.substring(0, charactersToShow),
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF1E4C1),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            shadows: [
              Shadow(color: ColorsManager.rafeeqYellow.withOpacity(0.4), blurRadius: 8),
            ],
          ),
        );
      },
    ).shimmer(
      delay: 1600.ms,
      duration: 2.seconds,
      color: ColorsManager.rafeeqYellow.withOpacity(0.3),
    );
  }

  Widget _buildDescriptionBody() {
    return Text(
      widget.scanResult.description ?? "",
      style: TextStyles.font14GreyMedium.copyWith(
        height: 1.8,
        color: ColorsManager.white.withOpacity(0.8),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildModernAudioBox() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildPlayButton(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Voice Guide", style: TextStyles.font18WhiteBold),
                      Text(
                          isProcessing ? "Optimizing..." : (isSpeaking ? "Narrating now..." : "Ready to explain"),
                          style: TextStyles.font14GreyMedium
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => isSettingsOpen = !isSettingsOpen),
                  icon: Icon(
                    isSettingsOpen ? Icons.expand_less : Icons.tune_rounded,
                    color: isSettingsOpen ? ColorsManager.rafeeqYellow : ColorsManager.white.withOpacity(0.5),
                  ),
                ).animate(target: isSettingsOpen ? 1 : 0).rotate(begin: 0, end: 0.25),
              ],
            ),
          ),
          if (isSettingsOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  _buildSliderRow("Speed", speechRate, 0.1, 1.0, (v) => _updateConfig(v, null)),
                  _buildSliderRow("Pitch", pitch, 0.5, 2.0, (v) => _updateConfig(null, v)),
                ],
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: isProcessing ? null : _handleSpeech,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSpeaking)
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.3)),
              ),
            ).animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(1,1), end: const Offset(1.5,1.5))
                .fadeOut(duration: 1.seconds),

          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isSpeaking ? Colors.transparent : ColorsManager.rafeeqYellow,
              shape: BoxShape.circle,
              border: Border.all(color: ColorsManager.rafeeqYellow, width: 2),
            ),
            child: isProcessing
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.black),
            )
                : Icon(
              isSpeaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isSpeaking ? ColorsManager.rafeeqYellow : ColorsManager.black,
              size: 30,
            ),
          ).animate(target: isSpeaking ? 1 : 0).shimmer(color: ColorsManager.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyles.font12YellowSemiBold)),
        Expanded(
          child: Slider(
            value: val, min: min, max: max,
            activeColor: ColorsManager.rafeeqYellow,
            inactiveColor: ColorsManager.white.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ),
        Text("${val.toStringAsFixed(1)}x", style: TextStyles.font12YellowSemiBold),
      ],
    );
  }

  Widget _buildSliverAppBar(Size size) {
    return SliverAppBar(
      expandedHeight: size.height * 0.45,
      backgroundColor: ColorsManager.black,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black45,
          child: Icon(Icons.arrow_back_ios_new, color: ColorsManager.white, size: 18),
        ),
        onPressed: () {
          _stopAndPop();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildResponsiveImage(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, ColorsManager.black],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveImage() {
    if (widget.localImagePath.isNotEmpty && !widget.localImagePath.startsWith('http')) {
      return Image.file(File(widget.localImagePath), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.network(widget.scanResult.images?.first ?? "", fit: BoxFit.cover),
      );
    }
    return Image.network(widget.scanResult.images?.first ?? "", fit: BoxFit.cover);
  }
}










/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// استبدل هذه المسارات بمسارات الملفات الحقيقية في مشروعك

import '../../../../../core/theming/theme.dart';
import 'scan_model.dart';

class ScanResultScreen extends StatefulWidget {
  final String localImagePath;
  final ScanModel scanResult;
  final String languageCode;

  const ScanResultScreen({
    super.key,
    required this.localImagePath,
    required this.scanResult,
    required this.languageCode,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late FlutterTts _flutterTts;
  bool isSpeaking = false;
  bool isSettingsOpen = false;
  bool isProcessing = false;
  double speechRate = 0.5;
  double pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(widget.languageCode);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() { isSpeaking = true; isProcessing = false; });
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() { isSpeaking = false; isProcessing = false; });
    });
  }

  @override
  void dispose() {
    // إيقاف الصوت وتنظيف الـ Handlers عند الخروج لمنع أي Logs في الخلفية
    _flutterTts.stop();
    _flutterTts.setStartHandler(() {});
    _flutterTts.setCompletionHandler(() {});
    super.dispose();
  }

  // ميثود ذكية لتغيير الإعدادات فوراً (Real-time)
  void _updateConfig(double? rate, double? p) async {
    setState(() {
      if (rate != null) speechRate = rate;
      if (p != null) pitch = p;
      isProcessing = true;
    });

    if (isSpeaking) {
      await _flutterTts.stop();
      _handleSpeech(); // إعادة التشغيل فوراً بالإعدادات الجديدة
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _handleSpeech() async {
    if (isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => isSpeaking = false);
    } else {
      if (mounted) setState(() => isProcessing = true);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.speak(widget.scanResult.description ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorsManager.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(size),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03),
                  _buildTitleSection(), // اسم المعلم باللون الأصفر
                  SizedBox(height: size.height * 0.025),
                  _buildModernAudioBox(size.width),
                  SizedBox(height: size.height * 0.04),
                  _buildAnimatedDescriptionTitle(), // الأنيميشن الفرعوني (مرة واحدة)
                  SizedBox(height: size.height * 0.015),
                  _buildDescriptionBody(),
                  SizedBox(height: size.height * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LANDMARK",
          style: TextStyles.font12YellowSemiBold.copyWith(letterSpacing: 2),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        const SizedBox(height: 5),
        Text(
          widget.scanResult.name?.toUpperCase() ?? "UNKNOWN LANDMARK",
          style: TextStyles.font26MontserratBlack.copyWith(
            color: ColorsManager.rafeeqYellow,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildAnimatedDescriptionTitle() {
    const String titleText = 'DESCRIPTION';
    return Text(
      titleText,
      style: GoogleFonts.cinzel(
        color: const Color(0xFFF1E4C1),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.0,
      ),
    ).animate(
      onPlay: (controller) => controller.forward(), // يعمل مرة واحدة فقط
    ).custom(
      duration: 1500.ms,
      builder: (context, value, child) {
        int charactersToShow = (value * titleText.length).floor();
        return Text(
          titleText.substring(0, charactersToShow),
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF1E4C1),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            shadows: [
              Shadow(color: ColorsManager.rafeeqYellow.withOpacity(0.4), blurRadius: 8),
            ],
          ),
        );
      },
    ).shimmer(
      delay: 1600.ms,
      duration: 2.seconds,
      color: ColorsManager.rafeeqYellow.withOpacity(0.3),
    );
  }

  Widget _buildDescriptionBody() {
    return Text(
      widget.scanResult.description ?? "",
      style: TextStyles.font14GreyMedium.copyWith(
        height: 1.8,
        color: ColorsManager.white.withOpacity(0.8),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildModernAudioBox(double width) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildPlayButton(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Voice Guide", style: TextStyles.font18WhiteBold),
                      Text(
                          isProcessing ? "Processing..." : (isSpeaking ? "Narrating now..." : "Ready to explain"),
                          style: TextStyles.font14GreyMedium
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => isSettingsOpen = !isSettingsOpen),
                  icon: Icon(
                    isSettingsOpen ? Icons.expand_less : Icons.tune_rounded,
                    color: isSettingsOpen ? ColorsManager.rafeeqYellow : ColorsManager.white.withOpacity(0.5),
                  ),
                ).animate(target: isSettingsOpen ? 1 : 0).rotate(begin: 0, end: 0.25),
              ],
            ),
          ),
          if (isSettingsOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  _buildSliderRow("Speed", speechRate, 0.1, 1.0, (v) => _updateConfig(v, null)),
                  _buildSliderRow("Pitch", pitch, 0.5, 2.0, (v) => _updateConfig(null, v)),
                ],
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: isProcessing ? null : _handleSpeech,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSpeaking)
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.3)),
              ),
            ).animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(1,1), end: const Offset(1.5,1.5))
                .fadeOut(duration: 1.seconds),

          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isSpeaking ? Colors.transparent : ColorsManager.rafeeqYellow,
              shape: BoxShape.circle,
              border: Border.all(color: ColorsManager.rafeeqYellow, width: 2),
            ),
            child: isProcessing
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.black),
            )
                : Icon(
              isSpeaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isSpeaking ? ColorsManager.rafeeqYellow : ColorsManager.black,
              size: 30,
            ),
          ).animate(target: isSpeaking ? 1 : 0).shimmer(color: ColorsManager.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyles.font12YellowSemiBold)),
        Expanded(
          child: Slider(
            value: val, min: min, max: max,
            activeColor: ColorsManager.rafeeqYellow,
            inactiveColor: ColorsManager.white.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ),
        Text("${val.toStringAsFixed(1)}x", style: TextStyles.font12YellowSemiBold),
      ],
    );
  }

  Widget _buildSliverAppBar(Size size) {
    return SliverAppBar(
      expandedHeight: size.height * 0.45,
      backgroundColor: ColorsManager.black,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black45,
          child: Icon(Icons.arrow_back_ios_new, color: ColorsManager.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildResponsiveImage(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, ColorsManager.black],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveImage() {
    if (widget.localImagePath.isNotEmpty && !widget.localImagePath.startsWith('http')) {
      return Image.file(File(widget.localImagePath), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.network(widget.scanResult.images?.first ?? "", fit: BoxFit.cover),
      );
    }
    return Image.network(widget.scanResult.images?.first ?? "", fit: BoxFit.cover);
  }
}*/