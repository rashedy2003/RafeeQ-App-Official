import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/networking/secure_storage_helper.dart';
import 'MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await SecureStorageHelper.getToken();
  bool isLoggedIn = (token != null && token.isNotEmpty);

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

  runApp(MyApp(isLoggedIn: isLoggedIn, initialLocale: Locale(initialLangCode)));
}