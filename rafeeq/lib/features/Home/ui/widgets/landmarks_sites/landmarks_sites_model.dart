class LandmarksSitesModel {
  final String name;
  final String type;
  final String primaryImageUrl;

  LandmarksSitesModel({
    required this.name,
    required this.type,
    required this.primaryImageUrl,
  });

  factory LandmarksSitesModel.fromJson(Map<String, dynamic> json) {
    return LandmarksSitesModel(
      name: json['name'] ?? 'No Name',
      type: json['typeDisplay'] ?? json['type'] ?? 'Unknown',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
    );
  }
}