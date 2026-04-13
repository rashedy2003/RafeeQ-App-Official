class CityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int totalSites;

  CityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.totalSites,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      // ✅ تأمين كامل لكل الحقول
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown City',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      totalSites: (json['totalSites'] ?? 0) as int,
    );
  }
}