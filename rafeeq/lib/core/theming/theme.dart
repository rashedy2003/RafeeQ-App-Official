import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorsManager {
  static const Color rafeeqYellow = Color(0xFFF2B90D);
  static const Color black = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color white = Colors.white;
}

class TextStyles {
  // 1. ستايل العناوين الضخمة (زي My Favorites)
  static TextStyle font26MontserratBlack = GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: ColorsManager.white,
  );

  // 2. السطر اللي كان ناقص ومسبب الـ Error
  static TextStyle font22WhiteBold = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: ColorsManager.white,
    letterSpacing: -0.2,
  );

  // 3. ستايل أسماء الأماكن (Main Card Title)
  static TextStyle font18WhiteBold = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  // 4. ستايل الوصف أو المدينة (Subtitles)
  static TextStyle font14GreyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  // 5. ستايل التصنيفات أو الأسعار (Labels)
  static TextStyle font12YellowSemiBold = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ColorsManager.rafeeqYellow,
  );
}