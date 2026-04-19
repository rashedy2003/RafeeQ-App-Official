class PlaceMarkerModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String imageUrl;

  PlaceMarkerModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.imageUrl,
  });

  factory PlaceMarkerModel.fromJson(Map<String, dynamic> json) {
    try {
      return PlaceMarkerModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? 'Unknown Place',
        // القراءة من الـ Nested Object (location)
        lat: double.parse(json['location']['latitude'].toString()),
        lng: double.parse(json['location']['longitude'].toString()),
        type: json['type'] ?? 'Site',
        imageUrl: json['imageUrl'] ?? '',
      );
    } catch (e) {
      // طباعة الخطأ في حال وجود مشكلة في بيانات مكان معين
      print("Error mapping place: ${json['name']}, error: $e");
      return PlaceMarkerModel(
        id: 'error',
        name: 'Parsing Error',
        lat: 0.0,
        lng: 0.0,
        type: 'Error',
        imageUrl: '',
      );
    }
  }
}