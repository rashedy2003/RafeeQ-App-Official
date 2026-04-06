import 'package:flutter/material.dart';
import '../../../../core/theming/theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/networking/secure_storage_helper.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: ColorsManager.rafeeqYellow),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),

          // ✅ زرار الـ Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await SecureStorageHelper.clearAll(); // مسح التوكنات
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.loginScreen,
                      (route) => false, // مسح تاريخ التنقلات
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