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
    // 1. معالجة قائمة الصور: بنسحب الـ url من جوه كل Object في قائمة الـ images
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List).map((item) {
        // الباك اند باعتها كـ Map فيها مفتاح url
        String url = item['url']?.toString() ?? '';
        if (url.contains("unsplash.com") && !url.contains("?")) {
          url += "?q=80&w=1000&auto=format&fit=crop";
        }
        return url;
      }).where((url) => url.isNotEmpty).toList();
    }

    // 2. معالجة سعر التذكرة بناءً على الـ Structure الجديد
    String fee = 'Free';
    if (json['isFree'] == false) {
      // بنحاول نوصل لسعر تذكرة المصريين كمثال للعرض الأساسي
      var ticketPrice = json['entryTicket']?['egyptianTicketPrice'];
      fee = ticketPrice?['formattedAmount']?.toString() ?? 'Price not set';
    }

    return LandmarkDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Landmark',
      description: json['description']?.toString() ?? 'No description available',
      typeDisplay: json['typeDisplay']?.toString() ?? '',

      // العنوان بقى String مباشر في الـ JSON الجديد
      fullAddress: json['address']?.toString() ?? 'No address provided',

      mainImageUrl: json['mainImageUrl']?.toString() ?? '',

      // تحويل الـ double بشكل آمن
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,

      entryFee: fee,

      // الإحداثيات جوه الـ location object
      latitude: double.tryParse(json['location']?['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['location']?['longitude']?.toString() ?? '0') ?? 0.0,

      images: imagesList,
    );
  }
}