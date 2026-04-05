import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theming/theme.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool isFavorite = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    // قراءة حالة المفضلة من البيانات القادمة
    isFavorite = widget.place['isFavorite'] == true;
  }

  // دالة فتح الخرائط العالمية (تشتغل أندرويد وآيفون)
  Future<void> _openMap() async {
    final address = widget.place['address'];

    // إحداثيات الأهرامات الحقيقية كـ Default لو الـ API مبعتش داتا
    final String lat = address?['latitude']?.toString() ?? "29.9792";
    final String lng = address?['longitude']?.toString() ?? "31.1342";

    // الرابط العالمي لفتح تطبيقات الخرائط الأصلية مباشرة
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final Uri appleMapsUrl = Uri.parse("http://maps.apple.com/?q=$lat,$lng");
    final Uri fallbackWebUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        // للأندرويد (يفتح تطبيق جوجل مابس)
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        // للآيفون (يفتح تطبيق خرائط أبل)
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // لو مفيش تطبيقات خالص يفتح المتصفح
        await launchUrl(fallbackWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening maps: $e");
      // محاولة أخيرة بالمتصفح في حالة حدوث أي خطأ غير متوقع
      await launchUrl(fallbackWebUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // معالجة البيانات بأمان (Null Safety) لضمان عدم حدوث Crash
    final List<dynamic> imagesList = widget.place['images'] is List ? widget.place['images'] : [];
    final Map<String, dynamic> address = widget.place['address'] ?? {};
    final String placeId = widget.place['id']?.toString() ?? 'place_rafeeq';

    return Scaffold(
      backgroundColor: const Color(0xFF121200),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. سلايدر الصور العلوي (Hero Animation)
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: const Color(0xFF121200),
            leading: _buildCircleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: imagesList.isEmpty
                  ? const Center(child: Icon(Icons.image_not_supported, color: Colors.white24, size: 50))
                  : PageView.builder(
                itemCount: imagesList.length,
                itemBuilder: (context, index) {
                  final String imageUrl = imagesList[index]['url']?.toString() ?? '';
                  return Hero(
                    tag: index == 0 ? placeId : 'img_${placeId}_$index',
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: Colors.white24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مؤشر عدد الصور (Dots Indicator)
                  if (imagesList.length > 1)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imagesList.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsManager.rafeeqYellow,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 2. الاسم والموقع وزر المفضلة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.place['name']?.toString() ?? 'Place Name',
                              style: const TextStyle(
                                  color: ColorsManager.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${address['region'] ?? ''}, ${address['city'] ?? ''}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildFavoriteButton(placeId),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 3. قسم الوصف (About) مع خاصية Expand
                  const Text(
                    "About this place",
                    style: TextStyle(color: ColorsManager.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.place['description']?.toString() ?? 'No description available.',
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        isExpanded ? "Read Less" : "Read More",
                        style: const TextStyle(color: ColorsManager.rafeeqYellow, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. بطاقات معلومات التذاكر والمواعيد
                  _buildInfoTile(
                    icon: Icons.confirmation_number_outlined,
                    title: "TICKET PRICE",
                    subtitle: widget.place['isFree'] == true
                        ? "Free Entrance"
                        : (widget.place['entryFee']?['formattedAmount']?.toString() ?? 'N/A'),
                  ),
                  _buildInfoTile(
                    icon: Icons.access_time,
                    title: "OPENING HOURS",
                    subtitle: (widget.place['openingHours'] is List && widget.place['openingHours'].isNotEmpty)
                        ? "${widget.place['openingHours'][0]['openTime']} - ${widget.place['openingHours'][0]['closeTime']}"
                        : "08:00 AM - 05:00 PM",
                  ),

                  const SizedBox(height: 25),

                  // 5. قسم الخريطة التفاعلي
                  const Text(
                    "Location",
                    style: TextStyle(color: ColorsManager.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _openMap, // الضغط هنا يفتح تطبيق الخرائط فوراً
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // صورة الخريطة (Static Map) تعتمد على إحداثيات الـ API
                          Image.network(
                            "https://static-maps.yandex.ru/1.x/?lang=en_US&ll=${address['longitude'] ?? 31.1342},${address['latitude'] ?? 29.9792}&z=14&l=map&size=600,300&theme=dark",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                          ),
                          // Marker لوكيشن في المنتصف
                          const Icon(Icons.location_on, color: Colors.red, size: 40),
                          // زر عائم للتوجيه
                          Positioned(
                            bottom: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: ColorsManager.rafeeqYellow.withOpacity(0.5)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.near_me, color: ColorsManager.rafeeqYellow, size: 16),
                                  SizedBox(width: 8),
                                  Text("Get Directions", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- الـ Widgets المساعدة (Helper Widgets) ---

  Widget _buildFavoriteButton(String id) {
    return GestureDetector(
      onTap: () {
        setState(() => isFavorite = !isFavorite);
        // هنا يتم ربط الـ Cubit لاحقاً
        debugPrint("Toggled Favorite for ID: $id");
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: ColorsManager.rafeeqYellow,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.3),
        child: IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onTap),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ColorsManager.rafeeqYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: ColorsManager.rafeeqYellow, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: ColorsManager.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}