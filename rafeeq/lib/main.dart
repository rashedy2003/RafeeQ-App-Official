import 'package:flutter/material.dart';
import 'core/networking/secure_storage_helper.dart';
import 'MyApp.dart';

void main() async {
  // ضروري جداً لتشغيل الـ Storage قبل الـ App
  WidgetsFlutterBinding.ensureInitialized();

  // فحص وجود التوكن
  String? token = await SecureStorageHelper.getToken();
  bool isLoggedIn = (token != null && token.isNotEmpty);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}