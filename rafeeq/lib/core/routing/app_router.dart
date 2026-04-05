import 'package:Rafeeq/features/Home/ui/home_screen.dart';
import 'package:flutter/material.dart';
import '../../features/auth/Login/ui/login.dart';
import '../../features/auth/register/ui/register_screen.dart';
import 'routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    Routes.registerScreen: (context) => const RegisterScreen(),
    Routes.loginScreen: (context) => const LoginScreen(),
    Routes.homeScreen: (context) => const HomeScreen(),
  };
}