import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../logic/home_cubit/home_cubit.dart';
import '../../logic/home_cubit/home_state.dart';
import 'LandmarkDetails/landmark_details_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => HomeCubit()..getHomeData(),
      child: Scaffold(
        backgroundColor: ColorsManager.black,
        body: BlocListener<LocaleCubit, Locale>(
          listener: (context, locale) {
            context.read<HomeCubit>().getHomeData();
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
                );
              }

              if (state is HomeError) {
                return _buildErrorState(state, loc, context);
              }

              if (state is HomeSuccess) {
                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().getHomeData(),
                  color: ColorsManager.rafeeqYellow,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: MediaQuery.of(context).padding.top + 15),

                            // 1. Must Visit
                            _buildSectionHeader(loc.must_visit),
                            const SizedBox(height: 15),
                            _buildHorizontalList(
                              height: screenHeight * 0.45,
                              itemCount: state.mustVisitItems.length,
                              itemBuilder: (context, index) => _buildMainCard(
                                context,
                                state.mustVisitItems[index],
                                screenWidth * 0.75,
                              ).animate(delay: (100 * index).ms).fadeIn(duration: 500.ms).slideX(begin: 0.2),
                            ),

                            const SizedBox(height: 30),

                            // 2. Special Offers
                            if (state.sponsors.isNotEmpty) ...[
                              _buildSectionHeader(loc.special_offers),
                              const SizedBox(height: 15),
                              _buildOffersList(context, state.sponsors, screenWidth),
                              const SizedBox(height: 30),
                            ],

                            // 3. Hidden Gems
                            _buildSectionHeader(loc.hidden_gems),
                            const SizedBox(height: 15),
                            _buildHorizontalList(
                              height: screenHeight * 0.32,
                              itemCount: state.hiddenGemsItems.length,
                              itemBuilder: (context, index) => _buildSmallCard(
                                context,
                                state.hiddenGemsItems[index],
                                screenWidth * 0.45,
                              ).animate(delay: (100 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                            ),

                            const SizedBox(height: 30),

                            // 4. Near You Header
                            _buildSectionHeader(loc.near_you),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),

                      // Near You Content مع معالجة حالة الـ Location
                      _buildNearYouSliverContent(state, loc),

                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets و Helper Methods ---

  Widget _buildNearYouSliverContent(HomeSuccess state, AppLocalizations loc) {
    if (!state.isLocationEnabled) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please enable location to see landmarks near you",
            style: TextStyles.font14GreyMedium.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    if (state.nearYouItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(loc.no_near_places, style: TextStyles.font14GreyMedium),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNearYouCard(context, state.nearYouItems[index])
              .animate(delay: (50 * index).ms)
              .fadeIn()
              .slideY(begin: 0.1),
          childCount: state.nearYouItems.length,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyles.font22WhiteBold.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 2.5.seconds,
                color: ColorsManager.rafeeqYellow.withOpacity(0.4)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: ColorsManager.rafeeqYellow, size: 11)
              .animate(onPlay: (c) => c.repeat())
              .moveX(
              begin: 0, end: 4, duration: 1.seconds, curve: Curves.easeInOut)
              .then()
              .moveX(begin: 4, end: 0, duration: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(
      {required double height,
        required int itemCount,
        required IndexedWidgetBuilder itemBuilder}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, dynamic item, double width) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: ColorsManager.surfaceDark,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _buildImage(item['primaryImageUrl'])),
            _buildGradientOverlay(),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: TextStyles.font18WhiteBold.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: ColorsManager.rafeeqYellow, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(item['city'] ?? '',
                              style: TextStyles.font14GreyMedium
                                  .copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearYouCard(BuildContext context, dynamic item) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: ColorsManager.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 75,
                height: 75,
                child: _buildImage(item['primaryImageUrl']),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: TextStyles.font18WhiteBold.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item['typeDisplay'] ?? '',
                      style: TextStyles.font12YellowSemiBold
                          .copyWith(fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      Text(" ${item['averageRating']}",
                          style: TextStyles.font14GreyMedium
                              .copyWith(fontSize: 11)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white54, size: 12),
                      Expanded(
                          child: Text(" ${item['city']}",
                              style: TextStyles.font14GreyMedium
                                  .copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(
      BuildContext context, List<dynamic> offers, double screenWidth) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            width: screenWidth * 0.8,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                ColorsManager.rafeeqYellow.withOpacity(0.15),
                Colors.black12
              ]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: ColorsManager.rafeeqYellow.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_rounded,
                    color: ColorsManager.rafeeqYellow, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['offerTitle'] ?? 'EXCLUSIVE',
                          style: TextStyles.font12YellowSemiBold.copyWith(
                              fontSize: 9, fontWeight: FontWeight.w900)),
                      Text(offer['title'] ?? '',
                          style: TextStyles.font18WhiteBold.copyWith(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text("${offer['discountPercentage']}%",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          );
        },
      ).animate().shimmer(duration: 2.seconds, color: Colors.white10),
    );
  }

  Widget _buildSmallCard(BuildContext context, dynamic item, double width) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImage(item['primaryImageUrl'])),
              ),
              const SizedBox(height: 8),
              Text(item['name'] ?? '',
                  style: TextStyles.font18WhiteBold.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(item['typeDisplay'] ?? '',
                  style:
                  TextStyles.font12YellowSemiBold.copyWith(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.white10),
      errorWidget: (_, __, ___) =>
      const Icon(Icons.broken_image, color: Colors.white10),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
            stops: const [0.0, 0.5],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(HomeError state, AppLocalizations loc, BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message,
                style: TextStyles.font18WhiteBold, textAlign: TextAlign.center),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.rafeeqYellow),
              onPressed: () => context.read<HomeCubit>().getHomeData(),
              child: Text(loc.retry,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}