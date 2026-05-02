import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';
import '../../logic/home_state.dart';
import 'home_landmark_card.dart';

class NearYouSliverContent extends StatelessWidget {
  final HomeSuccess state;
  final AppLocalizations loc;

  const NearYouSliverContent({super.key, required this.state, required this.loc});

  @override
  Widget build(BuildContext context) {
    if (!state.isLocationEnabled) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Please enable location", style: TextStyles.font14GreyMedium),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = state.nearYouItems[index];
            final String siteId = item['id'].toString();

            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LandmarkDetailsScreen(siteId: siteId))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: ColorsManager.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(width: 75, height: 75, child: HomeLandmarkImage(url: item['mainImageUrl'] ?? item['primaryImageUrl']))
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] ?? '', style: TextStyles.font18WhiteBold.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(item['typeDisplay'] ?? '', style: TextStyles.font12YellowSemiBold.copyWith(fontSize: 11)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              // حل مشكلة الـ String subtype int هنا أيضاً بـ toString()
                              Text(" ${item['averageRating']?.toString() ?? '0'}", style: TextStyles.font14GreyMedium.copyWith(fontSize: 11)),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_outlined, color: Colors.white54, size: 12),
                              Expanded(child: Text(" ${item['cityName'] ?? item['city'] ?? ''}", style: TextStyles.font14GreyMedium.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                  ],
                ),
              ),
            ).animate(delay: (50 * index).ms).fadeIn().slideY(begin: 0.1);
          },
          childCount: state.nearYouItems.length,
        ),
      ),
    );
  }
}