class LandmarkDetailsModel {
  final String id;
  final String name;
  final String description;
  final String typeDisplay;
  final String fullAddress;
  final String mainImageUrl;
  final double averageRating;
  final String entryFee;
  final double latitude;
  final double longitude;
  final List<String> images;

  LandmarkDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.typeDisplay,
    required this.fullAddress,
    required this.mainImageUrl,
    required this.averageRating,
    required this.entryFee,
    required this.latitude,
    required this.longitude,
    required this.images,
  });

  factory LandmarkDetailsModel.fromJson(Map<String, dynamic> json) {
    // معالجة قائمة الصور
    var imagesList = (json['images'] as List?)
        ?.map((item) => item['url'] as String)
        .toList() ?? [];

    return LandmarkDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      typeDisplay: json['typeDisplay'] ?? '',
      fullAddress: json['address']?['fullAddress'] ?? 'No address provided',
      mainImageUrl: json['mainImageUrl'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      entryFee: json['entryFee']?['formattedAmount'] ?? 'N/A',
      latitude: json['location']?['latitude'] ?? 0.0,
      longitude: json['location']?['longitude'] ?? 0.0,
      images: imagesList,
    );
  }
}