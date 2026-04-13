import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/networking/api_handler.dart'; // ✅ مهم جداً
import '../../../../../core/localization/locale_cubit.dart'; // ✅ للترجمة
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
      // ✅ نضمن استخدام الـ Dio العالمي اللي فيه الهيدرز
      future: ApiHandler.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F0F),
            body: Center(child: CircularProgressIndicator(color: Colors.amber)),
          );
        }

        return BlocProvider(
          create: (context) => LandmarkDetailsCubit(
            LandmarkDetailsApiService(snapshot.data!),
          )..getInitialData(widget.siteId),
          child: Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            // ✅ الـ Listener لمراقبة تغيير اللغة وتحديث البيانات فوراً
            body: BlocListener<LocaleCubit, Locale>(
              listener: (context, locale) {
                context.read<LandmarkDetailsCubit>().getInitialData(widget.siteId);
              },
              child: BlocBuilder<LandmarkDetailsCubit, LandmarkDetailsState>(
                buildWhen: (previous, current) =>
                current is! LandmarkDetailsSuccess ||
                    (previous is! LandmarkDetailsSuccess || previous.isMoreLoading != current.isMoreLoading),
                builder: (context, state) {
                  if (state is LandmarkDetailsLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
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
                            child: const Text("Retry"),
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(site.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(site.typeDisplay, style: const TextStyle(color: Colors.amber, fontSize: 16)),
                                const SizedBox(height: 20),
                                _buildIconInfo(Icons.location_on, site.fullAddress),
                                const SizedBox(height: 15),
                                _buildIconInfo(Icons.confirmation_number, "Entry Fee: ${site.entryFee}"),
                                const SizedBox(height: 30),
                                const Text("Description", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text(site.description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                                const SizedBox(height: 30),
                                const _TopAttractionsHeader(),
                                const SizedBox(height: 15),
                                _AttractionsList(siteId: widget.siteId, attractions: state.attractions, isMoreLoading: state.isMoreLoading),
                                const SizedBox(height: 30),
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
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0F0F0F),
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
            IgnorePointer(
              child: Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),
            ),
            if (site.images.length > 1)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: site.images.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 7,
                      dotWidth: 7,
                      activeDotColor: Colors.amber,
                      dotColor: Colors.white54,
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
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15))),
      ],
    );
  }
}

// الكلاسات الفرعية (_TopAttractionsHeader, _AttractionsList, _AttractionCard, _MapPreview)
// تظل كما هي في كودك الأصلي...

// --- تنظيف الكلاسات الفرعية لضمان الأداء وعدم التكرار ---

class _TopAttractionsHeader extends StatelessWidget {
  const _TopAttractionsHeader();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Top Attractions", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text("SEE ALL", style: TextStyle(color: Colors.white54, fontSize: 12)),
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
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: attractions.length + (isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < attractions.length) {
            return _AttractionCard(attraction: attractions[index]);
          } else {
            context.read<LandmarkDetailsCubit>().loadMoreAttractions(siteId);
            return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CircularProgressIndicator(color: Colors.amber)));
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttractionDetailsScreen(attractionId: attraction.id))),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: attraction.primaryImageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 350,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => Container(color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white24)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 10, right: 10,
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
        final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        height: 180, width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/map.png", fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.white10)),
            Container(color: Colors.black38),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                  SizedBox(height: 5),
                  Text("View on Google Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}