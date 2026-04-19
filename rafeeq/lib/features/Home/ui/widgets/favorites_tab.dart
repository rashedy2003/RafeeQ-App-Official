import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

// استيرادات المشروع
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'Favorite/FavoriteModel.dart';
import 'Favorite/FavoritesCubit.dart';
import 'LandmarkDetails/landmark_details_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<LocaleCubit, Locale>(
      listener: (context, locale) {
        context.read<FavoritesCubit>().fetchFavorites();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsiveness
          int crossAxisCount = constraints.maxWidth > 600 ? (constraints.maxWidth > 900 ? 4 : 3) : 2;
          final double itemWidth = constraints.maxWidth / crossAxisCount;
          final int cacheWidth = (itemWidth * MediaQuery.of(context).devicePixelRatio).round();

          return Scaffold(
            backgroundColor: ColorsManager.black, // اللون الجديد من الكور
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 80.0,
                  floating: true,
                  elevation: 0,
                  backgroundColor: ColorsManager.black,
                  centerTitle: false,
                  title: SizedBox(
                    height: 45,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: AnimatedTextKit(
                        key: ValueKey(Localizations.localeOf(context).languageCode),
                        animatedTexts: [
                          ColorizeAnimatedText(
                            loc.my_favorites_places,
                            textStyle: TextStyles.font26MontserratBlack, // الخط الجديد
                            colors: [
                              ColorsManager.white,
                              ColorsManager.rafeeqYellow,
                              const Color(0xFFF0BD2D),
                              ColorsManager.white,
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
                              TextButton(
                                onPressed: () => context.read<FavoritesCubit>().fetchFavorites(),
                                child: Text(loc.retry, style: TextStyles.font12YellowSemiBold),
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
      ),
    );
  }

  // --- التعديل هنا: إضافة الميثودز اللي كانت مسببة الـ Error ---

  Widget _buildFavoriteCard(BuildContext context, FavoriteModel item, int cacheWidth) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LandmarkDetailsScreen(siteId: item.siteId))),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.surfaceDark, // استخدام لون السطح الجديد
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
                memCacheWidth: cacheWidth,
                placeholder: (_, __) => Container(color: Colors.white10),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white10),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.siteName,
                      style: TextStyles.font18WhiteBold.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  Text(item.siteTypeDisplay,
                      style: TextStyles.font14GreyMedium.copyWith(fontSize: 10, color: Colors.white.withOpacity(0.6))
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => context.read<FavoritesCubit>().toggleFavorite(item.siteId),
                child: const CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 16,
                  child: Icon(Icons.favorite, color: ColorsManager.rafeeqYellow, size: 18),
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
          const Icon(Icons.favorite_border_rounded, color: Colors.white10, size: 80)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 15),
          Text(loc.no_favorites, style: TextStyles.font18WhiteBold),
        ],
      ),
    );
  }
}