import 'package:Rafeeq/features/Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/networking/api_handler.dart'; // ✅ استخدم الهاندلر بتاعنا
import '../../../../../core/localization/locale_cubit.dart'; // ✅ للترجمة الفورية
import 'landmarks_sites_api_service.dart';
import 'landmarks_sites_cubit.dart';
import 'landmarks_sites_state.dart';
import 'landmarks_sites_model.dart';

class LandmarksSitesScreen extends StatelessWidget {
  final String cityId;
  final String cityName;

  const LandmarksSitesScreen({
    super.key,
    required this.cityId,
    required this.cityName
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // بنجيب الـ Dio الجاهز اللي فيه الـ Interceptors (اللغة والتوكن)
        future: ApiHandler.getDio(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F0F0F),
              body: Center(child: CircularProgressIndicator(color: Colors.amber)),
            );
          }

          return BlocProvider(
            create: (context) => LandmarksSitesCubit(
              LandmarksSitesApiService(snapshot.data!), // بنباصي الـ Dio الصح
            )..getLandmarksSites(cityId),
            child: Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
              appBar: AppBar(
                centerTitle: true,
                title: Text(cityName, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              // ✅ الـ Listener السحري للترجمة الفورية
              body: BlocListener<LocaleCubit, Locale>(
                listener: (context, locale) {
                  context.read<LandmarksSitesCubit>().getLandmarksSites(cityId);
                },
                child: BlocBuilder<LandmarksSitesCubit, LandmarksSitesState>(
                  builder: (context, state) {
                    if (state is LandmarksSitesLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.amber));
                    }
                    if (state is LandmarksSitesError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(state.message,
                                  style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                            ),
                            ElevatedButton(
                              onPressed: () => context.read<LandmarksSitesCubit>().getLandmarksSites(cityId),
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      );
                    }
                    if (state is LandmarksSitesSuccess) {
                      if (state.sites.isEmpty) {
                        return const Center(
                          child: Text("No sites found", style: TextStyle(color: Colors.white)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.sites.length,
                        itemBuilder: (context, index) => _buildSiteCard(context, state.sites[index]),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildSiteCard(BuildContext context, LandmarksSitesModel site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LandmarkDetailsScreen(siteId: site.id),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            site.primaryImageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
          ),
        ),
        title: Text(
          site.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            site.type,
            style: const TextStyle(color: Colors.amber, fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      ),
    );
  }
}