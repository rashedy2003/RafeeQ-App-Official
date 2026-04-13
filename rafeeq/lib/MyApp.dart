import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Locale initialLocale;

  const MyApp({super.key, required this.isLoggedIn, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(initialLocale),
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
            initialRoute: isLoggedIn ? Routes.homeScreen : Routes.loginScreen,
            routes: AppRouter.routes,
          );
        },
      ),
    );
  }
}