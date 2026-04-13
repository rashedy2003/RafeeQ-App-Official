import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theming/theme.dart';
import '../../../../core/localization/locale_cubit.dart'; // ✅ أضفنا الـ import ده
import '../../logic/home_cubit/home_cubit.dart';
import '../../logic/home_cubit/home_state.dart';
import 'LandmarkDetails/landmark_details_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return BlocProvider(
      // بنعمل نداء للداتا أول ما الكيوبيت يتكريت
      create: (context) => HomeCubit()..getHomeData(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        // ✅ الـ BlocListener هنا هو اللى بيخلى الصفحة تعمل ريفريش لما اللغة تتغير
        body: BlocListener<LocaleCubit, Locale>(
          listener: (context, locale) {
            // أول ما لغة الأبلكيشن تتغير، نحدث بيانات الهوم فوراً
            context.read<HomeCubit>().getHomeData();
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
                );
              } else if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().getHomeData(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              } else if (state is HomeSuccess) {
                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().getHomeData(),
                  color: ColorsManager.rafeeqYellow,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 10),

                        // 1. Must Visit
                        _buildSectionHeader('Must Visit'),
                        const SizedBox(height: 15),
                        _buildHorizontalList(
                          height: screenHeight * 0.45,
                          itemCount: state.mustVisitItems.length,
                          itemBuilder: (context, index) => _buildMainCard(
                            context,
                            state.mustVisitItems[index],
                            screenWidth * 0.75,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 2. Special Offers (Featured Deals)
                        if (state.sponsors.isNotEmpty) ...[
                          _buildSectionHeader('Special Offers'),
                          const SizedBox(height: 15),
                          _buildOffersList(context, state.sponsors),
                          const SizedBox(height: 25),
                        ],

                        // 3. Hidden Gems
                        _buildSectionHeader('Hidden Gems'),
                        const SizedBox(height: 15),
                        _buildHorizontalList(
                          height: screenHeight * 0.35,
                          itemCount: state.hiddenGemsItems.length,
                          itemBuilder: (context, index) => _buildSmallCard(
                            context,
                            state.hiddenGemsItems[index],
                            screenWidth * 0.48,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 4. Near You Section
                        _buildSectionHeader('Near You'),
                        const SizedBox(height: 15),
                        state.nearYouItems.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "No places found near your current location.",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: state.nearYouItems.length,
                          itemBuilder: (context, index) =>
                              _buildNearYouCard(context, state.nearYouItems[index]),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
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

  // --- Helpers (أبقيناها كما هي لضمان التصميم) ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildHorizontalList(
      {required double height, required int itemCount, required IndexedWidgetBuilder itemBuilder}) {
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
          context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white10),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _buildImage(item['primaryImageUrl'])),
            _buildGradientOverlay(),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 1),
                  Text(item['city'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
          context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration:
        BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(width: 90, height: 90, child: _buildImage(item['primaryImageUrl'])),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(item['typeDisplay'] ?? '',
                      style: const TextStyle(color: ColorsManager.rafeeqYellow, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(" ${item['averageRating']}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on, color: Colors.white54, size: 14),
                      Text(" ${item['city']}",
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(BuildContext context, List<dynamic> offers) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            width: MediaQuery.sizeOf(context).width * 0.8,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: ColorsManager.rafeeqYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: ColorsManager.rafeeqYellow, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['offerTitle'] ?? 'Deal',
                          style: const TextStyle(
                              color: ColorsManager.rafeeqYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(offer['title'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text("${offer['discountPercentage']}% OFF",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, dynamic item, double width) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: item['id']))),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), child: _buildImage(item['primaryImageUrl']))),
            const SizedBox(height: 10),
            Text(item['name'] ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(item['typeDisplay'] ?? '',
                style: const TextStyle(color: ColorsManager.rafeeqYellow, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      memCacheHeight: 400,
      placeholder: (_, __) => Container(color: Colors.white10),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white10),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
              stops: const [0.0, 0.5],
            ),
          ),
        ),
      ),
    );
  }
}