import 'package:Rafeeq/features/Home/ui/widgets/profile/Profile_Screen.dart';
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

    // قائمة اللغات المدعومة
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
          // لوجو التطبيق في الهيدر
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: Image.asset("assets/images/Radeqcenter.png", height: 120),
            ),
          ),

          // زرار الصفحة الرئيسية
          ListTile(
            leading: const Icon(Icons.home_outlined, color: ColorsManager.rafeeqYellow),
            title: Text(loc.home, style: const TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),

          // ✅ زرار البروفايل (الجديد)
          ListTile(
            leading: const Icon(Icons.person_outline, color: ColorsManager.rafeeqYellow),
            title: const Text("Profile", style: TextStyle(color: Colors.white)), // يمكنك استبدالها بـ loc.profile لو معرفة عندك
            onTap: () {
              Navigator.pop(context); // غلق الدراور
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          // زرار الإعدادات
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: ColorsManager.rafeeqYellow),
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
                              trailing: context.read<LocaleCubit>().state.languageCode == lang['code']
                                  ? const Icon(Icons.check_circle, color: ColorsManager.rafeeqYellow)
                                  : null,
                              onTap: () async {
                                await context.read<LocaleCubit>().changeLanguage(lang['code']!);
                                if (context.mounted) {
                                  context.read<HomeCubit>().getHomeData();
                                }
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

          const Divider(color: Colors.white10, indent: 20, endIndent: 20),

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
            child: Text('RafeeQ v1.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}