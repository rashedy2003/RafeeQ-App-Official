import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/networking/secure_storage_helper.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/home_cubit/home_cubit.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // قائمة اللغات المدعومة مع أسمائها للعرض
    final List<Map<String, String>> languages = [
      {'name': 'العربية', 'code': 'ar'},
      {'name': 'English', 'code': 'en'},
      {'name': 'Deutsch (German)', 'code': 'de'},
      {'name': 'Français (French)', 'code': 'fr'},
      {'name': 'Italiano (Italian)', 'code': 'it'},
      {'name': 'Русский (Russian)', 'code': 'ru'},
      {'name': '日本語 (Japanese)', 'code': 'ja'},
      {'name': '中文 (Chinese)', 'code': 'zh'},
    ];

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

          // ✅ زرار تغيير اللغة (يدعم الـ 8 لغات مع تحديث فوري)
          ListTile(
            leading: const Icon(Icons.language, color: ColorsManager.rafeeqYellow),
            title: Text(loc.changeLanguage,
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    backgroundColor: ColorsManager.black,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: ColorsManager.rafeeqYellow, width: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      loc.chooseLanguage,
                      style: const TextStyle(color: ColorsManager.rafeeqYellow),
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: languages.map((lang) {
                            return ListTile(
                              title: Text(
                                lang['name']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              // إظهار علامة "صح" بجانب اللغة المختارة حالياً
                              trailing: context.read<LocaleCubit>().state.languageCode == lang['code']
                                  ? const Icon(Icons.check_circle, color: ColorsManager.rafeeqYellow)
                                  : null,
                              onTap: () async {
                                // 1. تغيير اللغة وحفظها في الـ SharedPreferences
                                await context.read<LocaleCubit>().changeLanguage(lang['code']!);

                                // 2. تحديث بيانات الصفحة الرئيسية فوراً باللغة الجديدة
                                if (context.mounted) {
                                  context.read<HomeCubit>().getHomeData();
                                }

                                // 3. قفل الـ Dialog والـ Drawer
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
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
            child: Text('RafeeQ v1.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}