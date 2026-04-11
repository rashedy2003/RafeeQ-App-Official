import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/networking/secure_storage_helper.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: ColorsManager.black,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: Image.asset("assets/images/Radeqcenter.png", height: 120),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: ColorsManager.rafeeqYellow),
            title: Text(loc.home, style: const TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: ColorsManager.rafeeqYellow),
            title: Text(loc.settings, style: const TextStyle(color: Colors.white)),
            onTap: () {},
          ),

          // ✅ زرار تغيير اللغة
          ListTile(
            leading: const Icon(Icons.language, color: ColorsManager.rafeeqYellow),
            title: Text(loc.changeLanguage,
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      loc.chooseLanguage,
                      style: const TextStyle(color: Colors.white),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('English',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            context.read<LocaleCubit>().changeToEnglish();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('العربية',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            context.read<LocaleCubit>().changeToArabic();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // ✅ Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              loc.logout,
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await SecureStorageHelper.clearAll();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.loginScreen,
                      (route) => false,
                );
              }
            },
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('RafeQ v1.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}