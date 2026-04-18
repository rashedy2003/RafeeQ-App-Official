import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MyApp.dart';
import 'core/networking/api_handler.dart';
import 'core/networking/secure_storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تشغيل الـ SecureStorage والـ Token
  String? token = await SecureStorageHelper.getToken();
  bool isLoggedIn = (token != null && token.isNotEmpty);

  // 2. إدارة اللغات المدعومة
  List<String> supportedLanguages = ['ar', 'en', 'de', 'fr', 'it', 'ru', 'ja', 'zh'];
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLang = prefs.getString('language_code');

  String initialLangCode;
  if (savedLang != null && supportedLanguages.contains(savedLang)) {
    initialLangCode = savedLang;
  } else {
    String deviceLang = Platform.localeName.split('_')[0];
    initialLangCode = supportedLanguages.contains(deviceLang) ? deviceLang : 'en';
    await prefs.setString('language_code', initialLangCode);
  }

  // 3. نمرر الـ Dio اللي تم إنشاؤه مسبقاً (اختياري للسرعة)
  final dio = await ApiHandler.getDio();

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    initialLocale: Locale(initialLangCode),
    dio: dio, // مررنا الـ dio هنا
  ));
}