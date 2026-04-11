import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // AppLocalizations instance
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // شبه Glass بدون Blur ثقيل
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: ColorsManager.rafeeqYellow,
          unselectedItemColor: Colors.white70,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: loc.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.document_scanner_outlined),
              label: loc.scan,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: loc.favs,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.turn_sharp_right_sharp),
              label: loc.trips,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.mode_of_travel),
              label: loc.governorates,
            ),
          ],
        ),
      ),
    );
  }
}