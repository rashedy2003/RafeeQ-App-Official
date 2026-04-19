class AttractionDetailsModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  // التعديل هنا: تحويلها إلى قائمة
  final List<String> historicalPeriods;
  final String locationDescription;
  final List<String> images;

  AttractionDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.historicalPeriods,
    required this.locationDescription,
    required this.images,
  });

  factory AttractionDetailsModel.fromJson(Map<String, dynamic> json) {
    var imagesList = (json['images'] as List)
        .map((img) => img['url'] as String)
        .toList();

    // التأكد من استخراج قائمة الفترات التاريخية بشكل صحيح
    var periodsList = (json['historicalPeriods'] as List?)
        ?.map((p) => p.toString())
        .toList() ?? [];

    return AttractionDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: json['location']['latitude']?.toDouble() ?? 0.0,
      longitude: json['location']['longitude']?.toDouble() ?? 0.0,
      historicalPeriods: periodsList,
      locationDescription: json['locationDescription'] ?? '',
      images: imagesList.isNotEmpty ? imagesList : [],
    );
  }
}