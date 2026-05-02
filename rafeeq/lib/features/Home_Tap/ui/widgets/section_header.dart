import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theming/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyles.font22WhiteBold.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 2.5.seconds,
                color: ColorsManager.rafeeqYellow.withOpacity(0.4)),
          ),
          const SizedBox(width: 8),
          // Animated arrow that moves left and right repeatedly
          const Icon(Icons.arrow_forward_ios_rounded, color: ColorsManager.rafeeqYellow, size: 11)
              .animate(onPlay: (c) => c.repeat())
              .moveX(begin: 0, end: 4, duration: 1.seconds, curve: Curves.easeInOut)
              .then()
              .moveX(begin: 4, end: 0, duration: 1.seconds),
        ],
      ),
    );
  }
}