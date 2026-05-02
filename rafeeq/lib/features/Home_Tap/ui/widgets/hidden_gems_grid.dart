import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theming/theme.dart';
import '../../../Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';
import 'home_landmark_card.dart';

class HiddenGemsList extends StatelessWidget {
  final List<dynamic> items;
  final double screenHeight;
  final double screenWidth;

  const HiddenGemsList({super.key, required this.items, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final String siteId = item['id'].toString();

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: siteId))),
            child: SizedBox(
              width: screenWidth * 0.45,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: HomeLandmarkImage(url: item['mainImageUrl'] ?? item['primaryImageUrl']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item['name'] ?? '', style: TextStyles.font18WhiteBold.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(item['typeDisplay'] ?? item['type'] ?? '', style: TextStyles.font12YellowSemiBold.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ).animate(delay: (100 * index).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }
}