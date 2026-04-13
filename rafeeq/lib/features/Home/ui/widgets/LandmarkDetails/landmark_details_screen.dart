import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/networking/api_constants.dart';
import 'Top_attractions/attraction_details_screen.dart';
import 'Top_attractions/attractions_model.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_cubit.dart';
import 'landmark_details_state.dart';
import 'landmark_details_model.dart';
// استيراد الصفحة الجديدة (تأكد من صحة المسار حسب مشروعك)

class LandmarkDetailsScreen extends StatelessWidget {
  final String siteId;

  const LandmarkDetailsScreen({super.key, required this.siteId});

  Future<void> _launchMap(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LandmarkDetailsCubit(
        LandmarkDetailsApiService(Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))),
      )..getInitialData(siteId),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: BlocBuilder<LandmarkDetailsCubit, LandmarkDetailsState>(
          builder: (context, state) {
            if (state is LandmarkDetailsLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }
            if (state is LandmarkDetailsError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            if (state is LandmarkDetailsSuccess) {
              final site = state.details;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: const Color(0xFF0F0F0F),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        site.mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24, size: 50),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(site.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          Text(site.typeDisplay, style: const TextStyle(color: Colors.amber, fontSize: 16)),
                          const SizedBox(height: 20),

                          _buildIconInfo(Icons.location_on, site.fullAddress),
                          const SizedBox(height: 15),
                          _buildIconInfo(Icons.confirmation_number, "Entry Fee: ${site.entryFee}"),

                          const SizedBox(height: 30),
                          const Text("Description", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(site.description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5)),

                          // --- قسم Top Attractions ---
                          const SizedBox(height: 30),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Top Attractions", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("SEE ALL", style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.attractions.length + (state.isMoreLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < state.attractions.length) {
                                  return _buildAttractionCard(context, state.attractions[index]);
                                } else {
                                  context.read<LandmarkDetailsCubit>().loadMoreAttractions(siteId);
                                  return const Center(child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: CircularProgressIndicator(color: Colors.amber),
                                  ));
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Text("Location", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          _buildMapPreview(site.latitude, site.longitude),
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
    );
  }

  Widget _buildAttractionCard(BuildContext context, AttractionModel attraction) {
    return GestureDetector(
      onTap: () {
        // الانتقال لصفحة تفاصيل الـ Attraction عند الضغط عليه
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttractionDetailsScreen(attractionId: attraction.id),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                attraction.primaryImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.white10),
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
              bottom: 10,
              left: 10,
              right: 10,
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

  Widget _buildMapPreview(double lat, double lng) {
    return GestureDetector(
      onTap: () => _launchMap(lat, lng),
      child: Container(
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/map.png", fit: BoxFit.cover),
            Container(color: Colors.black26),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                  Text("View on Google Maps", style: TextStyle(color: Colors.white)),
                ],
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