import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../../../core/networking/api_constants.dart';
import '../landmarks_sites/landmarks_sites_screen.dart';
import 'cities_api_service.dart';
import 'cities_cubit.dart';
import 'cities_state.dart';
import 'city_model.dart';



class GovernoratesTab extends StatelessWidget {
  const GovernoratesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
// In governorates_tab.dart

      create: (context) => CitiesCubit(
        CitiesApiService(
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl, // 👈 This tells Dio where to go
              receiveDataWhenStatusError: true,
            ),
          ),
        ),
      )..getCities(),      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                const Text(
                  "Select Region",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Discover sites by city to tailor your Egyptian journey.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: BlocBuilder<CitiesCubit, CitiesState>(
                    builder: (context, state) {

                      if (state is CitiesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is CitiesError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (state is CitiesSuccess) {
                        return GridView.builder(
                          itemCount: state.cities.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final city = state.cities[index];
                            return _buildCityCard(context, city);
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, CityModel city) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandmarksSitesScreen(
              cityId: city.id,
              cityName: city.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 38,
              backgroundImage: NetworkImage(city.imageUrl),
            ),

            const SizedBox(height: 12),

            Text(
              city.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${city.totalSites} Sites",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttractionsScreen extends StatelessWidget {
  final String governorateName;

  const AttractionsScreen({super.key, required this.governorateName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      appBar: AppBar(
        title: Text(governorateName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}