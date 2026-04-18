import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports الخاصة بمشروعك
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'Favorite/FavoriteModel.dart';
import 'Favorite/FavoritesCubit.dart';
import 'LandmarkDetails/landmark_details_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Localization: تعريف ملف الترجمة
    final loc = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 2. Responsiveness: تحديد عدد الأعمدة بناءً على عرض الشاشة
        int crossAxisCount = constraints.maxWidth > 600 ? (constraints.maxWidth > 900 ? 4 : 3) : 2;

        // حساب عرض الكارت الواحد لضبط جودة الصورة المخبأة (Caching)
        final double itemWidth = constraints.maxWidth / crossAxisCount;
        final int cacheWidth = (itemWidth * MediaQuery.of(context).devicePixelRatio).round();

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 3. Animated Titles: الـ AppBar الاحترافي
              SliverAppBar(
                expandedHeight: 80.0,
                floating: true,
                elevation: 0,
                backgroundColor: const Color(0xFF0A0A0A),
                centerTitle: false,
                title: SizedBox(
                  height: 45,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: AnimatedTextKit(
                      // تغيير الـ Key مع تغير اللغة لضمان تحديث الأنيميشن فوراً
                      key: ValueKey(Localizations.localeOf(context).languageCode),
                      animatedTexts: [
                        ColorizeAnimatedText(
                          loc.my_favorites_places, // النص المترجم
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                          colors: [
                            Colors.white,
                            ColorsManager.rafeeqYellow, // أصفر رفيق
                            const Color(0xFFF0BD2D),    // دهبي فخم
                            Colors.white,
                          ],
                          speed: const Duration(milliseconds: 300),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                    ),
                  ),
                ),
              ),

              // الـ Grid الخاص بالمفضلات
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow)),
                    );
                  }

                  if (state is FavoritesSuccess) {
                    if (state.favorites.isEmpty) {
                      return SliverFillRemaining(child: _buildEmptyState(context, loc));
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return _buildFavoriteCard(context, state.favorites[index], cacheWidth)
                                .animate(delay: (60 * index).ms)
                                .fadeIn(duration: 500.ms)
                                .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack);
                          },
                          childCount: state.favorites.length,
                        ),
                      ),
                    );
                  }

                  if (state is FavoritesError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => context.read<FavoritesCubit>().fetchFavorites(),
                              child: Text(loc.retry, style: const TextStyle(color: ColorsManager.rafeeqYellow)),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteModel item, int cacheWidth) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LandmarkDetailsScreen(siteId: item.siteId)),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'landmark-${item.siteId}',
              child: CachedNetworkImage(
                imageUrl: item.siteImageUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheWidth, // تحسين الأداء بناءً على الريسبونسيف
                placeholder: (_, __) => Container(color: Colors.white10),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white10),
              ),
            ),
            // تدرج لوني فخم
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent
                  ],
                ),
              ),
            ),
            // بيانات المكان
            Positioned(
              bottom: 12, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.siteName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: ColorsManager.rafeeqYellow, size: 10),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.siteTypeDisplay,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // زر القلب بتأثير نبض
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => context.read<FavoritesCubit>().toggleFavorite(item.siteId),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 16,
                  child: const Icon(Icons.favorite, color: ColorsManager.rafeeqYellow, size: 18)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border_rounded, color: Colors.white10, size: 90)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2.seconds, color: ColorsManager.rafeeqYellow.withOpacity(0.2)),
          const SizedBox(height: 15),
          Text(
            loc.no_favorites,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            loc.start_adding,
            style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}