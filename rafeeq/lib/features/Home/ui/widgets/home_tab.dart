import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/theme.dart';
import '../../logic/home_cubit/home_cubit.dart';
import '../../logic/home_cubit/home_state.dart';
import '../screens/place_details_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String getValue(Map item, String key, [String def = '']) {
    return item[key]?.toString() ?? def;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..getHomeData(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorsManager.rafeeqYellow));
          } else if (state is HomeError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.white)));
          } else if (state is HomeSuccess) {
            return _buildHomeContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeSuccess state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kToolbarHeight + 20),

          _buildSectionHeader('Must Visit'),
          const SizedBox(height: 15),
          SizedBox(
            height: 360,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: state.mustVisitItems.length,
              itemBuilder: (context, index) {
                final item = state.mustVisitItems[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlaceDetailsScreen(place: item)),
                  ),
                  child: _buildMainCard(item),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          _buildSectionHeader('Hidden Gems'),
          const SizedBox(height: 15),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: state.hiddenGemsItems.length,
              itemBuilder: (context, index) {
                final item = state.hiddenGemsItems[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlaceDetailsScreen(place: item)),
                  ),
                  child: _buildSmallScrollCard(item),
                );
              },
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorsManager.white)),
    );
  }

  Widget _buildMainCard(Map item) {
    final title = getValue(item, 'title', getValue(item, 'name'));
    final image = item['image'] ??
        (item['images'] != null && item['images'].isNotEmpty
            ? item['images'][0]['url']
            : '');
    final desc = getValue(item, 'description');
    final price = getValue(item, 'price');

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: item['id'] ?? title,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    ColorsManager.black.withOpacity(0.85),
                    Colors.transparent
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text(price,
                      style: const TextStyle(

                          color: ColorsManager.rafeeqYellow)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallScrollCard(Map item) {
    final title = getValue(item, 'title', getValue(item, 'name'));
    final image = item['image'] ??
        (item['images'] != null && item['images'].isNotEmpty
            ? item['images'][0]['url']
            : '');
    final desc = getValue(item, 'description');

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Hero(
              tag: item['id'] ?? title,
              child: Image.network(
                image,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey, height: 130),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}