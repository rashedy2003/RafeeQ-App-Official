import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/networking/api_handler.dart';
import '../../../../../core/localization/locale_cubit.dart';
import 'cities_api_service.dart';
import 'cities_cubit.dart';
import 'cities_state.dart';
import 'city_model.dart';
import '../landmarks_sites/landmarks_sites_screen.dart';

class GovernoratesTab extends StatelessWidget {
  const GovernoratesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // الريكوست ده مش هيبدأ غير لما LazyLoadWrapper في الهوم يبني التاب دي
      future: ApiHandler.getDio(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        return BlocProvider(
          // الـ Cubit بيبدأ يسحب الداتا (getCities) أول ما التاب تظهر
          create: (context) => CitiesCubit(
            CitiesApiService(snapshot.data!),
          )..getCities(),
          child: Scaffold(
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
                      child: BlocListener<LocaleCubit, Locale>(
                        listener: (context, locale) {
                          context.read<CitiesCubit>().getCities();
                        },
                        child: BlocBuilder<CitiesCubit, CitiesState>(
                          builder: (context, state) {
                            if (state is CitiesLoading) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.amber),
                              );
                            }
                            if (state is CitiesError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(state.message, style: const TextStyle(color: Colors.red)),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => context.read<CitiesCubit>().getCities(),
                                      child: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (state is CitiesSuccess) {
                              return GridView.builder(
                                itemCount: state.cities.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              backgroundColor: Colors.white10,
            ),
            const SizedBox(height: 12),
            Text(
              city.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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