class LandmarksSitesModel {
  final String id;
  final String name;
  final String type;
  final String primaryImageUrl;

  LandmarksSitesModel({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryImageUrl,
  });

  factory LandmarksSitesModel.fromJson(Map<String, dynamic> json) {
    return LandmarksSitesModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      type: json['typeDisplay']?.toString() ?? json['type']?.toString() ?? 'Unknown',
      primaryImageUrl: json['primaryImageUrl']?.toString() ?? '',
    );
  }
}