import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'features/Home/ui/widgets/Favorite/FavoritesApiService.dart';
import 'features/Home/ui/widgets/Favorite/FavoritesCubit.dart';
import 'l10n/app_localizations.dart';


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Locale initialLocale;
  final Dio dio; // أضفنا الـ Dio هنا

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.initialLocale,
    required this.dio,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ استخدام MultiBlocProvider لحل مشكلة الإيرور نهائياً
    return MultiBlocProvider(
      providers: [
        // 1. كيوبيت اللغة
        BlocProvider(create: (_) => LocaleCubit(initialLocale)),

        // 2. كيوبيت المفضلات (Global) ليكون متاح في كل الصفحات
        BlocProvider(
          create: (_) => FavoritesCubit(FavoritesApiService(dio))..fetchFavorites(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            locale: locale,
            supportedLocales: const [
              Locale('en'), Locale('ar'), Locale('de'), Locale('fr'),
              Locale('it'), Locale('ru'), Locale('ja'), Locale('zh'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            // تحديد مسار البداية بناءً على حالة تسجيل الدخول
            initialRoute: isLoggedIn ? Routes.homeScreen : Routes.loginScreen,
            routes: AppRouter.routes,
          );
        },
      ),
    );
  }
}