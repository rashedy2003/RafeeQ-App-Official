class AttractionModel {
  final String id;
  final String name;
  final String primaryImageUrl;

  AttractionModel({
    required this.id,
    required this.name,
    required this.primaryImageUrl,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    return AttractionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
    );
  }
}