import 'package:flutter/material.dart';
import '../../../../core/theming/theme.dart';

class GovernoratesTab extends StatelessWidget {
  const GovernoratesTab({super.key});

  // قائمة المحافظات (بدون صور حالياً)
  static final List<Map<String, String>> governorates = [
    {"name": "Cairo", "attractions": "142"},
    {"name": "Giza", "attractions": "110"},
    {"name": "Alexandria", "attractions": "55"},
    {"name": "Luxor", "attractions": "89"},
    {"name": "Aswan", "attractions": "64"},
    {"name": "Red Sea", "attractions": "70"},
    {"name": "South Sinai", "attractions": "60"},
    {"name": "North Sinai", "attractions": "20"},
    {"name": "Fayoum", "attractions": "35"},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                // Title
                const Text(
                  "Select Region",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Discover attractions by city to tailor your Egyptian journey.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: governorates.length,
                  itemBuilder: (context, index) {
                    final city = governorates[index];
                    return _buildCityCard(context, city);
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // كارت المحافظة
  Widget _buildCityCard(BuildContext context, Map<String, String> city) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttractionsScreen(governorateName: city['name']!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // placeholder بدل الصورة
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.rafeeqYellow,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 38,
                backgroundColor: Colors.black54,
                child: Icon(
                  Icons.location_city,
                  color: ColorsManager.rafeeqYellow,
                  size: 32,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              city['name']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${city['attractions']} Attractions",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Screen المعالم السياحية
class AttractionsScreen extends StatelessWidget {
  final String governorateName;

  const AttractionsScreen({super.key, required this.governorateName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,

      appBar: AppBar(
        title: Text(governorateName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),


    );
  }
}