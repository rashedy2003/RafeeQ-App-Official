import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/networking/api_constants.dart';
import 'landmark_details_api_service.dart';
import 'landmark_details_cubit.dart';
import 'landmark_details_state.dart';
import 'landmark_details_model.dart';

class LandmarkDetailsScreen extends StatelessWidget {
  final String siteId;

  const LandmarkDetailsScreen({super.key, required this.siteId});

  // Function لفتح تطبيق الخرائط الخارجي باستخدام الإحداثيات
  Future<void> _launchMap(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LandmarkDetailsCubit(
        LandmarkDetailsApiService(
          Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
        ),
      )..getLandmarkDetails(siteId),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: BlocBuilder<LandmarkDetailsCubit, LandmarkDetailsState>(
          builder: (context, state) {
            if (state is LandmarkDetailsLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }
            if (state is LandmarkDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              );
            }
            if (state is LandmarkDetailsSuccess) {
              final site = state.details;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: const Color(0xFF0F0F0F),
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        site.mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50, color: Colors.white24),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(site.name,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(site.typeDisplay,
                              style: const TextStyle(color: Colors.amber, fontSize: 16)),
                          const SizedBox(height: 20),

                          _buildIconInfo(Icons.location_on, site.fullAddress),
                          const SizedBox(height: 15),
                          _buildIconInfo(Icons.confirmation_number, "Entry Fee: ${site.entryFee}"),

                          const SizedBox(height: 30),
                          const Text("Description",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(site.description,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5)),

                          const SizedBox(height: 30),
                          const Text("Location",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),

                          // --- مستطيل الخريطة المحدث باستخدام الصورة المحلية ---
                          GestureDetector(
                            onTap: () => _launchMap(site.latitude, site.longitude),
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
                                  // استخدام الصورة التي قمت برفعها
                                  Image.asset(
                                    "assets/images/map.png",
                                    fit: BoxFit.cover,
                                  ),
                                  // طبقة تعتيم خفيفة مع أيقونة في النص لتوضيح الغرض
                                  Container(color: Colors.black26),
                                  const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                                        SizedBox(height: 4),
                                        Text("Tap to View on Google Maps",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  // زر الاتجاهات في الركن
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.location_on_sharp, color: Colors.red, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 15))),
      ],
    );
  }
}