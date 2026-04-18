import 'package:Rafeeq/features/Home/ui/widgets/profile/profile_cubit.dart';
import 'package:Rafeeq/features/Home/ui/widgets/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:ui';

import '../../../../../core/theming/theme.dart';
import 'ProfileModel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..getProfileData(),
      child: Scaffold(
        backgroundColor: ColorsManager.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text("My Profile",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),

        // ✅ زر التعديل: تم رفعه قليلاً باستخدام Padding سفلي
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileSuccess) {
                return FloatingActionButton(
                  backgroundColor: ColorsManager.rafeeqYellow,
                  elevation: 10,
                  onPressed: () => _showUpdateSheet(context, state.user),
                  child: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 30),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut);
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow));
            } else if (state is ProfileSuccess) {
              final user = state.user;
              return SingleChildScrollView( // ✅ Responsive support
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // ✅ كارت الهوية الزجاجي
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsManager.rafeeqYellow.withOpacity(0.1)
                                ),
                                child: const Icon(Icons.person_rounded, color: ColorsManager.rafeeqYellow, size: 40),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'RafeeQ User',
                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email ?? '',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slide(begin: const Offset(0, 0.2)),

                    const SizedBox(height: 40), // توزيع مساحة أفضل

                    // ✅ بوكسات الإحصائيات (تم تكبيرها)
                    Row(
                      children: [
                        _buildLargeGlassStat("Trips", user.totalTrips?.toString() ?? '0', Icons.explore_outlined),
                        const SizedBox(width: 15),
                        _buildLargeGlassStat("Reviews", user.totalReviews?.toString() ?? '0', Icons.star_border_rounded),
                      ],
                    ).animate().fadeIn(delay: 300.ms).slide(begin: const Offset(-0.1, 0)),

                    const SizedBox(height: 40),

                    _buildSectionTitle("ACCOUNT DETAILS"),
                    const SizedBox(height: 15),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _buildModernRow(Icons.account_circle_outlined, "Username", user.userName),
                          _buildModernRow(Icons.flag_outlined, "Nationality", user.nationality),
                          _buildModernRow(Icons.event_available_outlined, "Member Since", user.createdAt?.split('T')[0], isLast: true),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms).slide(begin: const Offset(0, 0.1)),

                    const SizedBox(height: 100), // مساحة إضافية للسكرول
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // --- تم تعديل هذا الـ Widget ليكون أكبر ---
  Widget _buildLargeGlassStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20), // تكبير الـ Padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorsManager.rafeeqYellow, size: 26), // تكبير الأيقونة
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), // تكبير الخط
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRow(IconData icon, String label, String? value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorsManager.rafeeqYellow.withOpacity(0.7), size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          const Spacer(),
          Text(value ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      "   $title",
      style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  void _showUpdateSheet(BuildContext context, ProfileModel user) {
    final fNameController = TextEditingController(text: user.firstName);
    final lNameController = TextEditingController(text: user.lastName);
    final nationalityController = TextEditingController(text: user.nationality);
    final cubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              left: 24, right: 24, top: 14
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF101010),
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Text("Update Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              _buildUpdateTextField(fNameController, "First Name", Icons.person_outline),
              _buildUpdateTextField(lNameController, "Last Name", Icons.person_outline),
              GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (Country country) => setState(() => nationalityController.text = country.name),
                  );
                },
                child: AbsorbPointer(child: _buildUpdateTextField(nationalityController, "Nationality", Icons.public_outlined)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.rafeeqYellow,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  cubit.updateProfileData(
                    firstName: fNameController.text,
                    lastName: lNameController.text,
                    nationality: nationalityController.text,
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text("Save", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: ColorsManager.rafeeqYellow, size: 18),
          filled: true,
          fillColor: Colors.white.withOpacity(0.02),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ColorsManager.rafeeqYellow)),
        ),
      ),
    );
  }
}