import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../../../core/networking/api_handler.dart';
import '../../../../../core/localization/locale_cubit.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/widgets/rafeeq_search_bar.dart';
import '../data/api/landmarks_sites_api_service.dart';
import '../logic/landmarks_sites_cubit.dart';
import '../logic/landmarks_sites_state.dart';
import 'LandmarksShimmerLoading.dart';
import 'widgets/landmark_site_card.dart';
import 'widgets/landmarks_error_widget.dart';

class LandmarksSitesScreen extends StatefulWidget {
  final String cityId;
  final String cityName;

  const LandmarksSitesScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<LandmarksSitesScreen> createState() => _LandmarksSitesScreenState();
}

class _LandmarksSitesScreenState extends State<LandmarksSitesScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // حساب عرض الشاشة لتعديل أحجام الخطوط والمسافات ديناميكياً
    final double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: ApiHandler.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LandmarksShimmerLoading();
        }

        return BlocProvider(
          create: (context) => LandmarksSitesCubit(
            LandmarksSitesApiService(snapshot.data!),
          )..getLandmarksSites(widget.cityId),
          child: Builder(
            builder: (context) {
              return Scaffold(
                backgroundColor: const Color(0xFF0F0F0F),
                // استخدام LayoutBuilder لضمان توافق الـ AppBar مع المساحة المتاحة
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.6), // لضمان عدم تداخل العنوان مع الأيقونات
                    child: SizedBox(
                      height: 40,
                      child: AnimatedTextKit(
                        repeatForever: true,
                        pause: const Duration(seconds: 5),
                        animatedTexts: [
                          TypewriterAnimatedText(
                            widget.cityName,
                            speed: const Duration(milliseconds: 150),
                            textStyle: GoogleFonts.philosopher(
                              fontSize: screenWidth < 360 ? 20 : 24, // تصغير الخط لو الشاشة صغيرة جداً
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: BlocListener<LocaleCubit, Locale>(
                  listener: (context, locale) {
                    context.read<LandmarksSitesCubit>().getLandmarksSites(
                      widget.cityId,
                      query: _searchController.text,
                    );
                  },
                  child: Column(
                    children: [
                      // قسم البحث: استخدام Padding ريسبونسف
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04, // 4% من عرض الشاشة
                          vertical: 12,
                        ),
                        child: RafeeqSearchBar(
                          controller: _searchController,
                          hintText: "${loc.search} ${widget.cityName}",
                          onChanged: (value) {
                            context.read<LandmarksSitesCubit>().getLandmarksSites(
                              widget.cityId,
                              query: value,
                            );
                          },
                        ),
                      ),

                      // عرض القائمة
                      Expanded(
                        child: BlocBuilder<LandmarksSitesCubit, LandmarksSitesState>(
                          builder: (context, state) {
                            if (state is LandmarksSitesLoading) {
                              return const LandmarksShimmerLoading();
                            }

                            if (state is LandmarksSitesError) {
                              return LandmarksErrorWidget(
                                errorKey: state.message,
                                onRetry: () => context.read<LandmarksSitesCubit>().getLandmarksSites(
                                  widget.cityId,
                                  query: _searchController.text,
                                ),
                              );
                            }

                            if (state is LandmarksSitesSuccess) {
                              if (state.sites.isEmpty) {
                                return Center(
                                  child: SingleChildScrollView( // لضمان عدم ظهور Error عند فتح الكيبورد في حالة الفراغ
                                    child: Text(
                                      loc.no_matches_found,
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                // جعل البادينج يعتمد على عرض الشاشة في التابلت
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth > 600 ? screenWidth * 0.1 : 16,
                                  vertical: 8,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.sites.length,
                                itemBuilder: (context, index) {
                                  return LandmarkSiteCard(
                                    site: state.sites[index],
                                  );
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}