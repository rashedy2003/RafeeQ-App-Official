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
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = (json['images'] as List).map((item) {
        String url = item['url']?.toString() ?? '';
        if (url.contains("unsplash.com") && !url.contains("?")) {
          url += "?q=80&w=1000&auto=format&fit=crop";
        }
        return url;
      }).where((url) => url.isNotEmpty).toList();
    }

    return LandmarkDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Landmark', // ✅ تأمين الاسم
      description: json['description']?.toString() ?? 'No description available', // ✅ تأمين الوصف
      typeDisplay: json['typeDisplay']?.toString() ?? '',
      fullAddress: json['address']?['fullAddress']?.toString() ?? 'No address provided',
      mainImageUrl: json['mainImageUrl']?.toString() ?? '',
      // ✅ التأكد من تحويل أي نوع بيانات لـ double بشكل آمن
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      entryFee: json['entryFee']?['formattedAmount']?.toString() ?? 'Free',
      latitude: double.tryParse(json['location']?['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['location']?['longitude']?.toString() ?? '0') ?? 0.0,
      images: imagesList,
    );
  }
}