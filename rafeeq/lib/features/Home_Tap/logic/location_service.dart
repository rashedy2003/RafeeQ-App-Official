import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Disabled';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Denied';
    }

    if (permission == LocationPermission.deniedForever) throw 'PermanentlyDenied';

    return await Geolocator.getCurrentPosition();
  }

  // ضيف الميثود دي هنا عشان تضيع الـ Error
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}