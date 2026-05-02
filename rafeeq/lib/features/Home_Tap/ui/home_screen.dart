import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/theme.dart';
import '../../../../core/widgets/rafeeq_search_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../landmarks_sites/data/models/landmarks_sites_model.dart';
import '../../landmarks_sites/ui/widgets/landmark_site_card.dart';
import '../data/api/home_tap_api_service.dart';
import '../data/repos/home_repo.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';

// Widgets
import 'widgets/must_visit_list.dart';
import 'widgets/special_offers_banner.dart';
import 'widgets/hidden_gems_grid.dart';
import 'widgets/near_you_section.dart';
import 'widgets/home_shimmer_loading.dart';
import 'widgets/home_location_error_widget.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/error_widget.dart';



class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => HomeCubit(HomeRepo(HomeApiService()))..getHomeData(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: ColorsManager.black,
            body: BlocBuilder<HomeCubit, HomeState>(
              // ✅ الـ buildWhen السحري اللي بيمنع الـ Shimmer لما نرجع من السيرش
              buildWhen: (prev, curr) => !(curr is HomeLoading && prev is HomeSuccess),
              builder: (context, state) {
                if (state is HomeLoading) return const HomeShimmerLoading();

                if (state is HomeError) {
                  return HomeErrorWidget(
                    messageKey: state.message,
                    loc: loc,
                    onRetry: () => context.read<HomeCubit>().getHomeData(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().getHomeData(),
                  color: ColorsManager.rafeeqYellow,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. السيرش بار (SliverAppBar عشان يختفي ويظهر بسلاسة)
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        backgroundColor: ColorsManager.black,
                        elevation: 0,
                        toolbarHeight: 90,
                        automaticallyImplyLeading: false,
                        title: RafeeqSearchBar(
                          controller: _searchController,
                          hintText: loc.search_egypt_landmarks,
                          onChanged: (query) => context.read<HomeCubit>().search(query),
                        ),
                      ),

                      // 2. المحتوى (سيرش أو الهوم الكاملة)
                      _buildBodyLogic(state, loc, size, context),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyLogic(HomeState state, AppLocalizations loc, Size size, BuildContext context) {
    // حالة تحميل البحث
    if (state is HomeSearchLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow)),
      );
    }

    // حالة نتائج البحث
    if (state is HomeSearchSuccess) {
      if (state.searchResults.isEmpty) {
        return SliverFillRemaining(
          child: Center(child: Text(loc.no_matches_found, style: const TextStyle(color: Colors.white54))),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final site = LandmarksSitesModel.fromJson(state.searchResults[index]);
              return LandmarkSiteCard(site: site).animate().fadeIn().slideY(begin: 0.1);
            },
            childCount: state.searchResults.length,
          ),
        ),
      );
    }

    // حالة الهوم (الداتا الأصلية)
    if (state is HomeSuccess) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                _buildHeader(loc.must_visit, loc),
                const SizedBox(height: 15),
                MustVisitList(items: state.mustVisitItems, screenHeight: size.height, screenWidth: size.width),
                const SizedBox(height: 30),

                if (state.sponsors.isNotEmpty) ...[
                  _buildHeader(loc.special_offers, loc),
                  const SizedBox(height: 15),
                  SpecialOffersBanner(offers: state.sponsors, screenWidth: size.width),
                  const SizedBox(height: 30),
                ],

                _buildHeader(loc.hidden_gems, loc),
                const SizedBox(height: 15),
                HiddenGemsList(items: state.hiddenGemsItems, screenHeight: size.height, screenWidth: size.width),
                const SizedBox(height: 30),

                _buildHeader(loc.near_you, loc),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // قسم الـ Near You (المنطق الأصلي الـ 100% بتاعك)
          if (state.isNearYouLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow)),
              ),
            )
          else if (!state.isLocationEnabled)
            SliverToBoxAdapter(
              child: HomeLocationErrorWidget(
                loc: loc,
                onEnablePressed: () => context.read<HomeCubit>().handleLocationRequest(),
              ),
            )
          else if (state.nearYouItems.isEmpty)
              const SliverToBoxAdapter(
                child: HomeEmptyState(message: "No places found nearby"),
              )
            else
              NearYouSliverContent(state: state, loc: loc),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildHeader(String title, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title, style: TextStyles.font22WhiteBold.copyWith(fontSize: 20))
              .animate().shimmer(duration: 2.seconds, color: ColorsManager.rafeeqYellow.withOpacity(0.3)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, color: ColorsManager.rafeeqYellow, size: 14),
        ],
      ),
    );
  }
}