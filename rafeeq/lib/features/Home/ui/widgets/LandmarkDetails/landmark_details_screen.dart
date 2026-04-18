import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/networking/api_handler.dart';
import '../../../../../core/localization/locale_cubit.dart';
import '../../../../../core/theming/theme.dart';
// ✅ تأكد من صحة مسار الـ FavoritesCubit
import '../Favorite/FavoritesCubit.dart';
import 'Top_attractions/attraction_details_screen.dart';
import 'Top_attractions/attractions_model.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_cubit.dart';
import 'landmark_details_state.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsScreen extends StatefulWidget {
  final String siteId;
  const LandmarkDetailsScreen({super.key, required this.siteId});

  @override
  State<LandmarkDetailsScreen> createState() => _LandmarkDetailsScreenState();
}

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiHandler.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F0F),
            body: Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow)),
          );
        }

        return BlocProvider(
          create: (context) => LandmarkDetailsCubit(
            LandmarkDetailsApiService(snapshot.data!),
          )..getInitialData(widget.siteId),
          child: Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            body: BlocListener<LocaleCubit, Locale>(
              listener: (context, locale) {
                context.read<LandmarkDetailsCubit>().getInitialData(widget.siteId);
              },
              child: BlocBuilder<LandmarkDetailsCubit, LandmarkDetailsState>(
                builder: (context, state) {
                  if (state is LandmarkDetailsLoading) {
                    return const Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow));
                  }
                  if (state is LandmarkDetailsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => context.read<LandmarkDetailsCubit>().getInitialData(widget.siteId),
                            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.rafeeqYellow),
                            child: const Text("Retry", style: TextStyle(color: Colors.black)),
                          )
                        ],
                      ),
                    );
                  }
                  if (state is LandmarkDetailsSuccess) {
                    final site = state.details;
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(site),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Header: Name, Type, and Global Favorite Button ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            site.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            site.typeDisplay,
                                            style: const TextStyle(
                                                color: ColorsManager.rafeeqYellow,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ✅ ربط زر القلب بالـ FavoritesCubit العالمي
                                    BlocBuilder<FavoritesCubit, FavoritesState>(
                                      builder: (context, favState) {
                                        final isFav = context.read<FavoritesCubit>().favIds.contains(site.id);
                                        return IconButton(
                                          onPressed: () {
                                            // استخدام الـ site.id لضمان مطابقة الريكويست مع الباك اند
                                            context.read<FavoritesCubit>().toggleFavorite(site.id);
                                          },
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? ColorsManager.rafeeqYellow : Colors.white54,
                                            size: 32,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 25),
                                _buildIconInfo(Icons.location_on_outlined, site.fullAddress),
                                const SizedBox(height: 15),
                                _buildIconInfo(Icons.confirmation_number_outlined, "Entry Fee: ${site.entryFee}"),

                                const SizedBox(height: 35),
                                const Text("Description", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Text(
                                  site.description,
                                  style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                                ),

                                const SizedBox(height: 35),
                                const _TopAttractionsHeader(),
                                const SizedBox(height: 15),
                                _AttractionsList(siteId: widget.siteId, attractions: state.attractions, isMoreLoading: state.isMoreLoading),

                                const SizedBox(height: 35),
                                const Text("Location", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 15),
                                _MapPreview(lat: site.latitude, lng: site.longitude),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(LandmarkDetailsModel site) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0F0F0F),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: site.images.isNotEmpty
                  ? PageView.builder(
                controller: _pageController,
                itemCount: site.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: site.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.white10),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white24),
                  );
                },
              )
                  : CachedNetworkImage(imageUrl: site.mainImageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
            ),
            if (site.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: site.images.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: ColorsManager.rafeeqYellow,
                      dotColor: Colors.white38,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ColorsManager.rafeeqYellow, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ],
    );
  }
}

// --- Helper Widgets Below ---

class _TopAttractionsHeader extends StatelessWidget {
  const _TopAttractionsHeader();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Top Attractions", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AttractionsList extends StatelessWidget {
  final String siteId;
  final List<AttractionModel> attractions;
  final bool isMoreLoading;
  const _AttractionsList({required this.siteId, required this.attractions, required this.isMoreLoading});

  @override
  Widget build(BuildContext context) {
    if (attractions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text("No attractions available nearby.", style: TextStyle(color: Colors.white38)),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: attractions.length + (isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < attractions.length) {
            return _AttractionCard(attraction: attractions[index]);
          } else {
            context.read<LandmarkDetailsCubit>().loadMoreAttractions(siteId);
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
              ),
            );
          }
        },
      ),
    );
  }
}

class _AttractionCard extends StatelessWidget {
  final AttractionModel attraction;
  const _AttractionCard({required this.attraction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AttractionDetailsScreen(attractionId: attraction.id))
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: attraction.primaryImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white24)
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 15, left: 12, right: 12,
              child: Text(
                attraction.name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final double lat, lng;
  const _MapPreview({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        height: 180, width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white.withOpacity(0.05)),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, color: ColorsManager.rafeeqYellow, size: 45),
                  SizedBox(height: 10),
                  Text("Tap to open Google Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}