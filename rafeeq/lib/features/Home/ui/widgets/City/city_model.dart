class CityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int totalSites;
  final CenterLocation? centerLocation; // الحقل الجديد

  CityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.totalSites,
    this.centerLocation,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown City',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      totalSites: (json['totalSites'] ?? 0) as int,
      // التأكد من وجود اللوكيشن قبل التحويل
      centerLocation: json['centerLocation'] != null
          ? CenterLocation.fromJson(json['centerLocation'])
          : null,
    );
  }
}

class CenterLocation {
  final double latitude;
  final double longitude;

  CenterLocation({
    required this.latitude,
    required this.longitude,
  });

  factory CenterLocation.fromJson(Map<String, dynamic> json) {
    return CenterLocation(
      // استخدام toDouble لضمان عدم حدوث خطأ إذا أرسل الباك إند القيمة كـ Integer
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}