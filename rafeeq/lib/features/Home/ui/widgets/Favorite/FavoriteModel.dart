class FavoriteModel {
  final String id;
  final String siteId;
  final String siteName;
  final String siteTypeDisplay;
  final String siteImageUrl;
  final double averageRating;

  FavoriteModel({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.siteTypeDisplay,
    required this.siteImageUrl,
    required this.averageRating,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id']?.toString() ?? '',
      siteId: json['siteId']?.toString() ?? '',
      siteName: json['siteName']?.toString() ?? '',
      siteTypeDisplay: json['siteTypeDisplay']?.toString() ?? '',
      siteImageUrl: json['siteImageUrl']?.toString() ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}