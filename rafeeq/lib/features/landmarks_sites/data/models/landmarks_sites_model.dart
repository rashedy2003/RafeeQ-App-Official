class LandmarksSitesModel {
  final String id;
  final String name;
  final String type;
  final String primaryImageUrl;
  final double averageRating;

  LandmarksSitesModel({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryImageUrl,
    required this.averageRating,
  });

  factory LandmarksSitesModel.fromJson(Map<String, dynamic> json) {
    return LandmarksSitesModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      // السيرفر بيبعت نوعين، بنفضل الـ Display لو موجود
      type: json['typeDisplay']?.toString() ?? json['type']?.toString() ?? 'Unknown',
      primaryImageUrl: json['primaryImageUrl']?.toString() ?? '',
      // تعديل الاسم من totalReviews لـ totalRating كما طلبت سابقاً
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}