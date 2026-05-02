import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../../../core/networking/api_handler.dart';
import '../../../../../core/localization/locale_cubit.dart';
import '../../../../../core/widgets/rafeeq_search_bar.dart';
import '../../../../../l10n/app_localizations.dart';
import '../logic/cities_cubit.dart';
import '../logic/cities_state.dart';
import '../data/api/cities_api_service.dart';
import 'widgets/city_card.dart';
import 'widgets/cities_error_widget.dart';

class GovernoratesTab extends StatefulWidget {
  const GovernoratesTab({super.key});

  @override
  State<GovernoratesTab> createState() => _GovernoratesTabState();
}

class _GovernoratesTabState extends State<GovernoratesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return FutureBuilder(
      future: ApiHandler.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        return BlocProvider(
          create: (context) => CitiesCubit(CitiesApiService(snapshot.data!))..getCities(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: _buildAnimatedHeader(loc),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverSearchBarDelegate(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // رفعنا الـ Blur شوية لجمالية أكتر
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            color: Colors.transparent, // ✅ شلنا اللون تماماً كما طلبت
                            child: _buildSearchBar(loc),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildGridContent(crossAxisCount, loc),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader(AppLocalizations loc) {
    return AnimatedTextKit(
      key: ValueKey(loc.journey_heart_egypt),
      animatedTexts: [
        ColorizeAnimatedText(
          loc.journey_heart_egypt,
          textStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
          colors: [Colors.white, Colors.amber, Colors.orangeAccent, Colors.white],
        ),
      ],
      isRepeatingAnimation: true,
    );
  }

  Widget _buildSearchBar(AppLocalizations loc) {
    return BlocBuilder<CitiesCubit, CitiesState>(
      builder: (context, state) {
        return RafeeqSearchBar(
          controller: _searchController,
          hintText: loc.search_governorate,
          onChanged: (query) {
            context.read<CitiesCubit>().filterCities(query);
          },
        );
      },
    );
  }

  Widget _buildGridContent(int crossAxisCount, AppLocalizations loc) {
    return BlocBuilder<CitiesCubit, CitiesState>(
      builder: (context, state) {
        if (state is CitiesLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }
        if (state is CitiesError) {
          return CitiesErrorWidget(error: state.message);
        }
        if (state is CitiesSuccess) {
          if (state.cities.isEmpty) return _buildNoResults(loc);

          return GridView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: state.cities.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              return CityCard(city: state.cities[index])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .scale(begin: const Offset(0.9, 0.9));
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoResults(AppLocalizations loc) {
    return Center(
      child: Text(loc.no_matches_found, style: const TextStyle(color: Colors.white24)),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverSearchBarDelegate({required this.child});

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) => false;
}