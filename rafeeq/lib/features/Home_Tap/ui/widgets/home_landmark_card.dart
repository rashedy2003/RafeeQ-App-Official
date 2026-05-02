import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Reusable Image widget with loading and error states
class HomeLandmarkImage extends StatelessWidget {
  final String? url;
  const HomeLandmarkImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      // Placeholder while loading
      placeholder: (_, __) => Container(color: Colors.white10),
      // Icon shown if image fails to load
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white10),
    );
  }
}

// Dark gradient overlay to make white text readable on images
class LandmarkGradientOverlay extends StatelessWidget {
  const LandmarkGradientOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
            stops: const [0.0, 0.5], // Gradient starts from bottom to middle
          ),
        ),
      ),
    );
  }
}