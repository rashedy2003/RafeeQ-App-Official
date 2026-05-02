import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theming/theme.dart';
import '../../../Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';
import 'home_landmark_card.dart';

class MustVisitList extends StatelessWidget {
  final List<dynamic> items;
  final double screenHeight;
  final double screenWidth;

  const MustVisitList({super.key, required this.items, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // تأمين الـ ID كـ String
          final String siteId = item['id'].toString();

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: siteId))),
            child: Container(
              width: screenWidth * 0.75,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: ColorsManager.surfaceDark,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // استخدام mainImageUrl بناءً على الـ Log
                  Positioned.fill(
                    child: HomeLandmarkImage(
                      url: item['mainImageUrl'] ?? item['primaryImageUrl'] ?? '',
                    ),
                  ),
                  const LandmarkGradientOverlay(),
                  Positioned(
                    bottom: 15, left: 15, right: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item['name'] ?? '', style: TextStyles.font18WhiteBold.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: ColorsManager.rafeeqYellow, size: 12),
                            const SizedBox(width: 4),
                            // تعديلcityName
                            Expanded(child: Text(item['cityName'] ?? item['city'] ?? '', style: TextStyles.font14GreyMedium.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: (100 * index).ms).fadeIn(duration: 500.ms).slideX(begin: 0.2);
        },
      ),
    );
  }
}