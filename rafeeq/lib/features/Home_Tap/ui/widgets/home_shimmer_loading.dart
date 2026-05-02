import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء لتناسب تصميم رفيق
      body: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Column(
          children: [
            // محاكاة لمنطقة الـ Header والـ Status Bar
            SizedBox(height: MediaQuery.of(context).padding.top + 20),

            // محاكاة لعنوان القسم (مثلاً Must Visit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 25,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // قائمة الكروت التي تملأ كامل طول الشاشة
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(), // منع التمرير أثناء الشيمر
                itemCount: 4, // عدد الكروت الكافي لملء الشاشة
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
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