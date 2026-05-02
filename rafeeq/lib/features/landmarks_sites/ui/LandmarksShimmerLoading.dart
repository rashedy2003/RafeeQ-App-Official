import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LandmarksShimmerLoading extends StatelessWidget {
  const LandmarksShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // نفس خلفية تطبيق RafeeQ
      body: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.05),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Column(
          children: [
            // 1. محاكاة الـ AppBar (العنوان في المنتصف)
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            Center(
              child: Container(
                height: 30,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. محاكاة الـ Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 3. قائمة الكروت (محاكاة لـ LandmarkSiteCard)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6, // عدد كافي لملء الشاشة
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      // محاكاة الصورة المستطيلة
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // محاكاة النصوص (الاسم والنوع)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: double.infinity,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 15,
                              width: 80,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              height: 12,
                              width: 40,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}