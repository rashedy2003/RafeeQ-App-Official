class ScanModel {
  final String? name;
  final String? siteName;
  final String? description;
  final List<String>? images;

  ScanModel({
    this.name,
    this.siteName,
    this.description,
    this.images,
  });

  // تحويل من JSON (Map) إلى ScanModel Object
  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      name: json['name'],
      siteName: json['siteName'],
      description: json['description'],
      // التأكد من تحويل القائمة بشكل صحيح وآمن
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}