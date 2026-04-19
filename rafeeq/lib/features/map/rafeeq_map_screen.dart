import 'package:Rafeeq/features/map/site_marker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports الخاصة بمشروعك
import 'package:Rafeeq/core/theming/theme.dart';
import '../Home/ui/widgets/LandmarkDetails/landmark_details_screen.dart';
import 'map_cubit.dart';
import 'map_state.dart';

class RafeeqMapScreen extends StatefulWidget {
  const RafeeqMapScreen({super.key});

  @override
  State<RafeeqMapScreen> createState() => _RafeeqMapScreenState();
}

class _RafeeqMapScreenState extends State<RafeeqMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isFirstFetch = true;

  // تحريك الكاميرا بسلاسة
  void _moveCamera(LatLng point, double zoom) {
    _mapController.move(point, zoom);
  }

  // ميثود الانتقال لصفحة التفاصيل (الحل الأكيد)
  void _navigateToDetails(BuildContext context, PlaceMarkerModel place) {
    // إغلاق الـ BottomSheet أولاً باستخدام Navigator الـ root
    Navigator.of(context).pop();

    // الانتقال لصفحة التفاصيل
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandmarkDetailsScreen(siteId: place.id),
      ),
    );

    debugPrint("✅ Navigating to Landmark: ${place.name} with ID: ${place.id}");
  }

  // عرض بطاقة المعاينة (Preview Card)
  void _showPlacePreview(BuildContext context, PlaceMarkerModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GestureDetector(
        // استخدام الـ context الأصلي لضمان عمل الـ Navigator
        onTap: () => _navigateToDetails(context, place),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorsManager.rafeeqYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place.type,
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator())
                  ),
                  errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, size: 40)
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "اضغط للمزيد من التفاصيل والمسح ثلاثي الأبعاد",
                style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم الماركر المخصص
  Widget _buildCustomMarker(PlaceMarkerModel place) {
    return GestureDetector(
      onTap: () => _showPlacePreview(context, place),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorsManager.rafeeqYellow, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Text(
              place.name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.location_on, color: Colors.redAccent, size: 35),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(),
      child: Scaffold(
        body: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            if (_userLocation == null) {
              _determineInitialPosition(context);
              return const Center(
                child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow),
              );
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation!,
                    initialZoom: 11.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    ),
                    MarkerLayer(
                      key: ValueKey(state is MapSuccess ? state.markers.length : 0),
                      markers: [
                        Marker(
                          point: _userLocation!,
                          width: 60, height: 60,
                          child: const Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 45),
                        ),
                        if (state is MapSuccess)
                          ...state.markers.map((place) => Marker(
                            point: LatLng(place.lat, place.lng),
                            width: 120, height: 85,
                            child: _buildCustomMarker(place),
                          )),
                      ],
                    ),
                  ],
                ),

                // أزرار التحكم
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: Column(
                    children: [
                      _buildMapButton(
                        icon: Icons.add,
                        onPressed: () => _moveCamera(_mapController.camera.center, _mapController.camera.zoom + 1),
                      ),
                      const SizedBox(height: 8),
                      _buildMapButton(
                        icon: Icons.remove,
                        onPressed: () => _moveCamera(_mapController.camera.center, _mapController.camera.zoom - 1),
                      ),
                      const SizedBox(height: 16),
                      _buildMapButton(
                        icon: Icons.my_location,
                        iconColor: Colors.blueAccent,
                        onPressed: () async {
                          Position position = await Geolocator.getCurrentPosition();
                          LatLng current = LatLng(position.latitude, position.longitude);
                          setState(() => _userLocation = current);
                          _moveCamera(current, 15.0);
                        },
                      ),
                    ],
                  ),
                ),

                if (state is MapLoading)
                  const Positioned(
                    top: 100, left: 0, right: 0,
                    child: Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed, Color iconColor = Colors.black87}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: IconButton(icon: Icon(icon, color: iconColor), onPressed: onPressed),
    );
  }

  Future<void> _determineInitialPosition(BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _userLocation = LatLng(position.latitude, position.longitude));
      if (_isFirstFetch && context.mounted) {
        context.read<MapCubit>().getNearbyMarkers(lat: position.latitude, lng: position.longitude);
        _isFirstFetch = false;
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }
}
























/*import 'package:Rafeeq/features/map/site_marker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rafeeq/core/theming/theme.dart';

import 'map_cubit.dart';
import 'map_state.dart';


class RafeeqMapScreen extends StatefulWidget {
  const RafeeqMapScreen({super.key});

  @override
  State<RafeeqMapScreen> createState() => _RafeeqMapScreenState();
}

class _RafeeqMapScreenState extends State<RafeeqMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isFirstFetch = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(),
      child: Scaffold(
        body: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {

            // 1. الانتظار حتى تحديد موقع المستخدم
            if (_userLocation == null) {
              _determineInitialPosition(context);
              return const Center(child: CircularProgressIndicator(color: ColorsManager.rafeeqYellow));
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation!,
                    initialZoom: 8.0, // زوم واسع لرؤية القاهرة من العبور
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    ),

                    MarkerLayer(
                      // الـ Key يضمن تحديث الماركرز فوراً عند نجاح الـ State
                      key: ValueKey(state is MapSuccess ? state.markers.length : 0),
                      markers: [
                        // ماركر موقع المستخدم (أزرق)
                        Marker(
                          point: _userLocation!,
                          width: 40, height: 40,
                          child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
                        ),

                        // رسم الماركرز الحقيقية من السيرفر (أحمر)
                        if (state is MapSuccess)
                          ...state.markers.map((place) => Marker(
                            point: LatLng(place.lat, place.lng),
                            width: 60, height: 60,
                            child: GestureDetector(
                              onTap: () => _showPlaceInfo(context, place),
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          )),
                      ],
                    ),
                  ],
                ),

                if (state is MapLoading)
                  const Positioned(top: 100, left: 0, right: 0, child: Center(child: CircularProgressIndicator())),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPlaceInfo(BuildContext context, PlaceMarkerModel place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (place.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  height: 180, width: double.infinity, fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _determineInitialPosition(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) setState(() => _userLocation = LatLng(position.latitude, position.longitude));

    if (_isFirstFetch && context.mounted) {
      context.read<MapCubit>().getNearbyMarkers(lat: position.latitude, lng: position.longitude);
      _isFirstFetch = false;
    }
  }
}*/