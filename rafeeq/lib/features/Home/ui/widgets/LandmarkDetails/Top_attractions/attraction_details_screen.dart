import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/networking/api_constants.dart';
import 'attraction_details_model.dart';

class AttractionDetailsScreen extends StatefulWidget {
  final String attractionId;
  const AttractionDetailsScreen({super.key, required this.attractionId});

  @override
  State<AttractionDetailsScreen> createState() => _AttractionDetailsScreenState();
}

class _AttractionDetailsScreenState extends State<AttractionDetailsScreen> {
  late Future<AttractionDetailsModel> _detailsFuture;
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchDetails();
  }

  @override
  void dispose() {
    _cancelToken.cancel(); // إلغاء الريكويست فور الخروج
    super.dispose();
  }

  Future<AttractionDetailsModel> _fetchDetails() async {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final response = await dio.get("attractions/${widget.attractionId}", cancelToken: _cancelToken);
    return AttractionDetailsModel.fromJson(response.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: FutureBuilder<AttractionDetailsModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 350, pinned: true, backgroundColor: const Color(0xFF0F0F0F),
                  flexibleSpace: FlexibleSpaceBar(
                    background: PageView.builder(
                      itemCount: data.images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: data.images[index],
                          fit: BoxFit.cover,
                          memCacheHeight: 1000,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildPeriodTag(data.historicalPeriodDisplay),
                        const SizedBox(height: 25),
                        const Text("About this place", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(data.description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                        const SizedBox(height: 30),
                        const Text("Location Details", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(data.locationDescription, style: const TextStyle(color: Colors.white60, fontSize: 15)),
                        const SizedBox(height: 30),
                        _buildMapPreview(data.latitude, data.longitude),
                        const SizedBox(height: 50),
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
    );
  }

  Widget _buildPeriodTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMapPreview(double lat, double lng) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(image: AssetImage("assets/images/map.png"), fit: BoxFit.cover),
        ),
        child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
      ),
    );
  }
}