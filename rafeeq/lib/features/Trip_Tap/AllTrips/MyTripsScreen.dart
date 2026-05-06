import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// ✅ Imports من الـ Core بتاعك
import '../../../core/theming/theme.dart';

import '../TripDetails/TripDetailsModel.dart';
import '../TripDetails/trip_details_screen.dart';
import '../TripsRepository.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late Future<List<TripDetailsModel>> _tripsFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _refreshTrips();
  }

  void _refreshTrips() {
    setState(() {
      _tripsFuture = TripsRepository().getAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorsManager.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: ColorsManager.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: DefaultTextStyle(
              style: GoogleFonts.cinzel(
                color: ColorsManager.rafeeqYellow,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'MY JOURNEYS',
                    speed: const Duration(milliseconds: 80),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            centerTitle: true,
          ),
          body: FutureBuilder<List<TripDetailsModel>>(
            future: _tripsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MyTripsShimmer();
              }
              if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final trips = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: 16,
                ),
                itemCount: trips.length,
                itemBuilder: (context, index) =>
                    _buildTripCard(trips[index], index),
              );
            },
          ),
        ),

        if (_isDeleting)
          Material( // ✅ ضيف الويدجت دي هنا
            color: Colors.transparent, // عشان ما تغطيش على اللون اللي إنت عامله
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: ColorsManager.rafeeqYellow),
                    const SizedBox(height: 20),
                    Text("Removing Expedition...",
                        style: TextStyles.font18WhiteBold),
                  ],
                ).animate().scale(duration: 300.ms),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripCard(TripDetailsModel trip, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailsScreen(tripId: trip.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              ColorsManager.surfaceDark.withOpacity(0.9),
              ColorsManager.surfaceDark.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: ColorsManager.rafeeqYellow.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.rafeeqYellow.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            /// 🔥 ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.rafeeqYellow.withOpacity(0.3),
                    ColorsManager.rafeeqYellow.withOpacity(0.05),
                  ],
                ),
              ),
              child:
              Icon(
                Icons.travel_explore_rounded,
                color: ColorsManager.rafeeqYellow,
                size: 26,
              )
            ),

            const SizedBox(width: 16),

            /// 🔥 TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font18WhiteBold.copyWith(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.startDate,
                          style: TextStyles.font14GreyMedium.copyWith(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "${trip.totalSites} Sites",
                        style: TextStyles.font14GreyMedium.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildStatusBadge(trip.statusDisplay),
                ],
              ),
            ),

            /// DELETE BUTTON
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.redAccent,
                size: 26,
              ),
              onPressed: () => _showDeleteDialog(trip),
            ),
          ],
        ),
      )
          .animate(delay: (index * 80).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            ColorsManager.rafeeqYellow.withOpacity(0.2),
            ColorsManager.rafeeqYellow.withOpacity(0.05),
          ],
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyles.font12YellowSemiBold,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore,
              size: 90, color: ColorsManager.rafeeqYellow.withOpacity(0.3))
              .animate()
              .scale(duration: 600.ms),

          const SizedBox(height: 20),

          Text(
            "No expeditions planned yet.",
            style: TextStyles.font14GreyMedium.copyWith(fontSize: 15),
          ),

          const SizedBox(height: 10),

          Text(
            "Start your first journey ✨",
            style: TextStyles.font12YellowSemiBold,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  void _showDeleteDialog(TripDetailsModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsManager.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Delete Journey?",
          style: TextStyles.font22WhiteBold
              .copyWith(color: ColorsManager.rafeeqYellow),
        ),
        content: Text(
          "Do you really want to erase '${trip.title}' from history?",
          style: TextStyles.font14GreyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Keep", style: TextStyles.font14GreyMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isDeleting = true);
              try {
                await TripsRepository().deleteTrip(trip.id);
                _refreshTrips();
              } finally {
                setState(() => _isDeleting = false);
              }
            },
            child: Text(
              "Delete",
              style: TextStyles.font18WhiteBold.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class MyTripsShimmer extends StatelessWidget {
  const MyTripsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 18),
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorsManager.black,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}