class LandmarksSitesModel {
  final String id; // 👈 زود السطر ده
  final String name;
  final String type;
  final String primaryImageUrl;

  LandmarksSitesModel({
    required this.id, // 👈 وزوده هنا
    required this.name,
    required this.type,
    required this.primaryImageUrl,
  });

  factory LandmarksSitesModel.fromJson(Map<String, dynamic> json) {
    return LandmarksSitesModel(
      id: json['id'] ?? '', // 👈 وزوده هنا
      name: json['name'] ?? 'No Name',
      type: json['typeDisplay'] ?? json['type'] ?? 'Unknown',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
    );
  }
}