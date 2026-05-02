import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/landmarks_sites_model.dart';
import '../../../Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';

class LandmarkSiteCard extends StatelessWidget {
  final LandmarksSitesModel site;
  const LandmarkSiteCard({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandmarkDetailsScreen(siteId: site.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // 🌌 الخلفية المتدرجة
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // 📦 محتوى الكارت
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // 🖼️ الصورة (كبيرة ومالية المساحة)
                    SizedBox(
                      width: 160,
                      height: double.infinity,
                      child: Hero(
                        tag: 'landmark-${site.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  site.primaryImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.black87, child: const Icon(Icons.image, color: Colors.white24)),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // 🧠 النصوص والأنيميشن الهادئ
                    Expanded(child: _buildText()),

                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
      // ✅ أنيميشن الكارت بالكامل (أبطأ بمرتين: 4 ثواني)
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: -4, end: 4, duration: 4.seconds, curve: Curves.easeInOut)
          .animate()
          .fadeIn(duration: 800.ms)
          .slideY(begin: 0.05, curve: Curves.easeOut),
    );
  }

  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🎨 هنا الألوان اللي سألت عليها (اللمعة الذهبية الهادئة)
        Text(
          site.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
          duration: 6.seconds, // ✅ أبطأ بكتير (6 ثواني) لراحة العين
          color: Colors.amber.withOpacity(0.15), // ✅ لون ذهبي باهت جداً وراقي
        ),

        const SizedBox(height: 10),

        // التصنيف
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.amber.withOpacity(0.08),
            border: Border.all(color: Colors.amber.withOpacity(0.15)),
          ),
          child: Text(
            site.type,
            style: GoogleFonts.notoSansArabic(
              fontSize: 10,
              color: Colors.amber[200],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // التقييم
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              site.averageRating.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}