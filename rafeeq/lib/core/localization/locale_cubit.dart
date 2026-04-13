import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  // الـ Constructor بياخد اللغة المبدئية اللي حددناها في الـ main
  LocaleCubit(Locale initialLocale) : super(initialLocale);

  // قائمة اللغات المدعومة للتأكد قبل الحفظ (اختياري لزيادة الأمان)
  final List<String> _supportedLanguages = [
    'ar', 'en', 'de', 'fr', 'it', 'ru', 'ja', 'zh'
  ];

  /// ميثود أساسية لتغيير اللغة
  /// [langCode] يجب أن يكون أحد الأكواد المدعومة مثل 'ar' أو 'zh'
  Future<void> changeLanguage(String langCode) async {
    // التأكد إن اللغة مدعومة قبل تنفيذ أي شيء
    if (!_supportedLanguages.contains(langCode)) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. حفظ الكود في الذاكرة (عشان الـ ApiHandler يقرأه)
      await prefs.setString('language_code', langCode);

      // 2. تحديث الـ UI باللغة الجديدة
      emit(Locale(langCode));

      debugPrint("✅ Language successfully changed to: $langCode");
    } catch (e) {
      debugPrint("❌ Error in LocaleCubit: $e");
    }
  }

  // ميثود مساعدة لو حابب ترجع اللغة الحالية كـ String
  String get currentLanguageCode => state.languageCode;
}