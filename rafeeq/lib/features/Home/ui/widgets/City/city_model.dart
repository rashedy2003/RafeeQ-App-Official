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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      totalSites: json['totalSites'],
    );
  }
}