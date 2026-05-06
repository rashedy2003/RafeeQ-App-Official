import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../TripsRepository.dart';
import 'TripDetailsModel.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {


  late Future<TripDetailsModel> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = TripsRepository().getTripDetails(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // لون أسود عميق للفخامة
      body: FutureBuilder<TripDetailsModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF1E4C1)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
          }

          final trip = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildAppBar(trip),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(trip),
                      const SizedBox(height: 20),
                      _buildDescription(trip),
                      const SizedBox(height: 25),
                      _buildQuickStats(trip),
                      const SizedBox(height: 30),
                      Text("ITINERARY",
                          style: GoogleFonts.cinzel(color: const Color(0xFFF1E4C1), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDaySection(trip.days[index]),
                  childCount: trip.days.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(TripDetailsModel trip) {
    return SliverAppBar(
      expandedHeight: 250, pinned: true, backgroundColor: const Color(0xFF1A1A1A),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(trip.title.toUpperCase(),
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFF1E4C1))),
        background: Stack(
          fit: StackFit.expand,
          children: [
            const Icon(Icons.explore_rounded, size: 100, color: Colors.white10),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(TripDetailsModel trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.statusDisplay.toUpperCase(),
                style: const TextStyle(color: Color(0xFFB08900), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFFF1E4C1), size: 16),
                const SizedBox(width: 5),
                Text("${trip.startDate} to ${trip.endDate}",
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF1E4C1), borderRadius: BorderRadius.circular(20)),
          child: Text(trip.toleranceDisplay,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildDescription(TripDetailsModel trip) {
    return Text(trip.description,
        style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5));
  }

  Widget _buildQuickStats(TripDetailsModel trip) {
    return Row(
      children: [
        _statItem("Budget", trip.estimatedBudget.formattedAmount, Icons.payments),
        _statItem("Duration", "${trip.estimatedTotalDurationMinutes}m", Icons.timer),
        _statItem("Sites", "${trip.totalSites}", Icons.place),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFF1E4C1), size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(TripDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFB08900), shape: BoxShape.circle),
                  child: Text("${day.dayNumber + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Text("DAY ${day.dayNumber + 1}",
                    style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(day.estimatedDayCost.formattedAmount,
                    style: const TextStyle(color: Color(0xFFF1E4C1), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ...day.sites.map((site) => _buildSiteCard(site)).toList(),
        ],
      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildSiteCard(TripSite site) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: site.siteImageUrl,
              width: 80, height: 80, fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.white10),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(site.siteName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("${site.cityName} • ${site.siteTypeDisplay}",
                    style: const TextStyle(color: Color(0xFFB08900), fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: Colors.white38, size: 14),
                    const SizedBox(width: 5),
                    Text(site.plannedArrivalTime, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 15),
                    const Icon(Icons.payments_outlined, color: Colors.white38, size: 14),
                    const SizedBox(width: 5),
                    Text(site.estimatedCost.formattedAmount, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../TripsRepository.dart';
// import 'TripDetailsModel.dart';
//
// class TripDetailsScreen extends StatefulWidget {
//   final String tripId;
//   const TripDetailsScreen({super.key, required this.tripId});
//
//   @override
//   State<TripDetailsScreen> createState() => _TripDetailsScreenState();
// }
//
// class _TripDetailsScreenState extends State<TripDetailsScreen> {
//   late Future<TripDetailsModel> _detailsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _detailsFuture = TripsRepository().getTripDetails(widget.tripId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A1A),
//       body: FutureBuilder<TripDetailsModel>(
//         future: _detailsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: Color(0xFFF1E4C1)));
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
//           }
//
//           final trip = snapshot.data!;
//           return CustomScrollView(
//             slivers: [
//               _buildAppBar(trip),
//               SliverToBoxAdapter(child: _buildTripInfo(trip)),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                       (context, index) => _buildDaySection(trip.days[index]),
//                   childCount: trip.days.length,
//                 ),
//               ),
//               const SliverToBoxAdapter(child: SizedBox(height: 50)),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildAppBar(TripDetailsModel trip) {
//     return SliverAppBar(
//       expandedHeight: 200, pinned: true, backgroundColor: const Color(0xFFB08900),
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(trip.title, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 16)),
//         background: const Icon(Icons.map_rounded, size: 80, color: Color(0xFFF1E4C1)),
//       ),
//     );
//   }
//
//   Widget _buildTripInfo(TripDetailsModel trip) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(trip.description, style: const TextStyle(color: Colors.white70)),
//           const Divider(color: Color(0xFFF1E4C1), height: 40),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDaySection(TripDay day) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: Text("Day ${day.dayNumber}", style: GoogleFonts.cinzel(color: const Color(0xFFF1E4C1), fontSize: 18)),
//         ),
//         ...day.sites.map((site) => ListTile(
//           leading: const Icon(Icons.location_on, color: Color(0xFFF1E4C1)),
//           title: Text(site.siteName, style: const TextStyle(color: Colors.white)),
//           subtitle: Text(site.plannedArrivalTime, style: const TextStyle(color: Colors.white54)),
//         )).toList(),
//       ],
//     ).animate().fadeIn().slideX();
//   }
// }