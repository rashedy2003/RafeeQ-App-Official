class AttractionDetailsModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String historicalPeriodDisplay;
  final String locationDescription;
  final List<String> images;

  AttractionDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.historicalPeriodDisplay,
    required this.locationDescription,
    required this.images,
  });

  factory AttractionDetailsModel.fromJson(Map<String, dynamic> json) {
    var imagesList = (json['images'] as List)
        .map((img) => img['url'] as String)
        .toList();

    return AttractionDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: json['location']['latitude']?.toDouble() ?? 0.0,
      longitude: json['location']['longitude']?.toDouble() ?? 0.0,
      historicalPeriodDisplay: json['historicalPeriodDisplay'] ?? '',
      locationDescription: json['locationDescription'] ?? '',
      images: imagesList.isNotEmpty ? imagesList : [],
    );
  }
}