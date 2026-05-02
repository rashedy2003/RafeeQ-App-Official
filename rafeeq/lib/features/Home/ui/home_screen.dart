import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Home_Tap/ui/home_screen.dart';
import '../../governorates/ui/governorates_tab.dart';
import '../logic/navigation_cubit/navigation_cubit.dart';
import '../logic/navigation_cubit/navigation_state.dart';
import 'widgets/favorites_tab.dart';
import 'widgets/scan_screen/scan_tab.dart';
import 'widgets/trips_tab.dart';
import '../../../core/theming/theme.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_background.dart';
import 'widgets/home_bottom_nav_bar.dart';

// --- الـ Wrapper الذكي لمنع تحميل الصفحات دفعة واحدة ---
class LazyLoadWrapper extends StatefulWidget {
  final Widget child;
  final bool isSelected;

  const LazyLoadWrapper({super.key, required this.child, required this.isSelected});

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    // بمجرد ما الصفحة تبقى Selected مرة واحدة، هتفضل محملة (Initialized)
    if (widget.isSelected && !_initialized) {
      _initialized = true;
    }

    if (!_initialized) {
      return const SizedBox.shrink(); // صفحة فارغة تماماً في الخلفية
    }

    return widget.child;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // حذفنا قائمة الـ pages الثابتة لأننا هنبنيها داخل الـ build مع الـ Wrapper

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          final int currentIndex = (state is NavigationInitial) ? state.index : 0;

          // قائمة الصفحات مغلفة بالـ LazyLoadWrapper
          final List<Widget> lazyPages = [
            LazyLoadWrapper(isSelected: currentIndex == 0, child: const HomeTab()),
            LazyLoadWrapper(isSelected: currentIndex == 1, child: const ScanTab()),
            LazyLoadWrapper(isSelected: currentIndex == 2, child: const FavoritesTab()),
            LazyLoadWrapper(isSelected: currentIndex == 3, child: const TripsTab()),
            LazyLoadWrapper(isSelected: currentIndex == 4, child: const GovernoratesTab()),
          ];

          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,

            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 85,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              leading: Center(
                child: Builder(
                  builder: (context) => IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: ColorsManager.rafeeqYellow,
                      size: 32,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              title: _buildPharaonicTitle(),
              actions: const [SizedBox(width: 56)],
            ),

            drawer: const HomeDrawer(),

            body: Stack(
              children: [
                const HomeBackground(),
                IndexedStack(
                  index: currentIndex,
                  children: lazyPages.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Widget page = entry.value;

                    return page.animate(target: currentIndex == idx ? 1 : 0)
                        .fade(duration: 600.ms, curve: Curves.easeOut);
                  }).toList(),
                ),
              ],
            ),

            bottomNavigationBar: HomeBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<NavigationCubit>().changePage(index);
              },
            ).animate().slideY(begin: 1, end: 0, duration: 800.ms, curve: Curves.easeOut),
          );
        },
      ),
    );
  }

  Widget _buildPharaonicTitle() {
    const String titleText = 'RafeeQ';
    return Text(
      titleText,
      style: GoogleFonts.cinzel(
        color: const Color(0xFFF1E4C1),
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: 5.0,
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: false),
    ).custom(
      duration: 60.seconds,
      builder: (context, value, child) {
        double writingPart = 0.02;
        int charactersToShow;
        if (value < writingPart) {
          charactersToShow = ((value / writingPart) * titleText.length).floor();
        } else {
          charactersToShow = titleText.length;
        }
        return Text(
          titleText.substring(0, charactersToShow),
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF1E4C1),
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 5.0,
            shadows: [
              Shadow(
                color: ColorsManager.rafeeqYellow.withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
        );
      },
    ).shimmer(
      delay: 2.seconds,
      duration: 2.seconds,
      color: ColorsManager.rafeeqYellow.withOpacity(0.5),
    );
  }
}