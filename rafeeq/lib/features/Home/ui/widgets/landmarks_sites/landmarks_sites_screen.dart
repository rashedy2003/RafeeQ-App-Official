import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../../core/networking/api_constants.dart';
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
    return BlocProvider(
      create: (context) => LandmarksSitesCubit(
        LandmarksSitesApiService(
          Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
        ),
      )..getLandmarksSites(cityId), // الطلب بيتم بالـ ID
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(cityName, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<LandmarksSitesCubit, LandmarksSitesState>(
          builder: (context, state) {
            if (state is LandmarksSitesLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }
            if (state is LandmarksSitesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              );
            }
            if (state is LandmarksSitesSuccess) {
              if (state.sites.isEmpty) {
                return const Center(
                  child: Text("No sites found in this city",
                      style: TextStyle(color: Colors.white)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.sites.length,
                itemBuilder: (context, index) => _buildSiteCard(state.sites[index]),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSiteCard(LandmarksSitesModel site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            site.primaryImageUrl,
            width: 80, height: 80, fit: BoxFit.cover,
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
      ),
    );
  }
}