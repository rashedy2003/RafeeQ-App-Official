import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theming/theme.dart';

class SpecialOffersBanner extends StatelessWidget {
  final List<dynamic> offers;
  final double screenWidth;

  const SpecialOffersBanner({super.key, required this.offers, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
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
              gradient: LinearGradient(colors: [ColorsManager.rafeeqYellow.withOpacity(0.15), Colors.black12]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_rounded, color: ColorsManager.rafeeqYellow, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['offerTitle'] ?? 'EXCLUSIVE', style: TextStyles.font12YellowSemiBold.copyWith(fontSize: 9, fontWeight: FontWeight.w900)),
                      Text(offer['title'] ?? '', style: TextStyles.font18WhiteBold.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Discount Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text("${offer['discountPercentage']}%", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          );
        },
      ).animate().shimmer(duration: 2.seconds, color: Colors.white10),
    );
  }
}