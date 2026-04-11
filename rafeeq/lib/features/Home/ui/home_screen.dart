import 'package:Rafeeq/features/Home/ui/widgets/City/governorates_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/navigation_cubit/navigation_cubit.dart';
import '../logic/navigation_cubit/navigation_state.dart';
import 'widgets/favorites_tab.dart';
import 'widgets/home_tab.dart';
import 'widgets/scan_screen/scan_tab.dart';
import 'widgets/trips_tab.dart';
import '../../../core/theming/theme.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_background.dart';
import 'widgets/home_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> pages = [
    HomeTab(),
    ScanTab(),
    FavoritesTab(),
    TripsTab(),
    GovernoratesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // بنستخدم BlocProvider عشان نوفر الـ Cubit للشاشة
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          // هنجيب الـ index الحالي من الـ state
          int currentIndex = 0; // default
          if (state is NavigationInitial) {
            currentIndex = state.index;
          }

          return Scaffold(

            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: ColorsManager.white),
              title: const Text(
                'Rafeeq',
                style: TextStyle(
                  color: ColorsManager.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            drawer: const HomeDrawer(),
            // جوه HomeScreen
            body: Stack(
              children: [
                const HomeBackground(),
                IndexedStack( // ده أسرع بكتير في التنقل
                  index: currentIndex,
                  children: pages,
                ),
              ],
            ),
            bottomNavigationBar: HomeBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                // بدل setState بننادي على الـ function اللي في الـ Cubit
                context.read<NavigationCubit>().changePage(index);
              },







            ),










          );
        },
      ),
    );
  }
}