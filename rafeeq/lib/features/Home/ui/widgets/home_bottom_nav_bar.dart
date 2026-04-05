import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theming/theme.dart';

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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined), label: "Scan"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favs"),
            BottomNavigationBarItem(
                icon: Icon(Icons.turn_sharp_right_sharp), label: "Trips"),
            BottomNavigationBarItem(
                icon: Icon(Icons.mode_of_travel), label: "Governorates"),
          ],
        ),
      ),
    );
  }
}