import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rafeeq',
      theme: ThemeData(
        brightness: Brightness.dark, // عشان يليق مع ستايل رافيق الأسود
      ),
      // اللوجيك السحري: لو مسجل دخول يروح الهوم، غير كدا يروح اللوجن
      initialRoute: isLoggedIn ? Routes.homeScreen : Routes.loginScreen,
      routes: AppRouter.routes,
    );
  }
}