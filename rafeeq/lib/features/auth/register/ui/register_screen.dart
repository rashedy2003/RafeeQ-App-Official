import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart'; // تأكد من المسار
import '../../../../core/theming/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // بنخليها true هنا عشان لما الكيبورد تفتح السكرول يشتغل تلقائي لو احتاجنا مساحة
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // 2. Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              // السطر ده هو السر: بيخلي السكرول مبيتحركش بإيد المستخدم خالص
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    Image.asset(
                      "assets/images/Radeqcenter.png",
                      height: 180, // قللت الحجم حاجة بسيطة عشان يناسب الشاشات الأصغر
                    ),

                    Text(
                      "Discover the wonders of Egypt",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.rafeeqYellow,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: emailController,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: passwordController,
                      label: 'PASSWORD',
                      isPassword: true,
                    ),

                    const SizedBox(height: 40),

                    // زرار التسجيل (SIGN UP)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // بعد التسجيل، بنوديه لصفحة الـ Login أو الـ Home حسب رغبتك
                          Navigator.pushNamed(context, Routes.loginScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.rafeeqYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // زرار العودة للـ Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: ColorsManager.rafeeqYellow),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.loginScreen);
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: ColorsManager.rafeeqYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "By signing up, you agree to Rafeq’s\nTerms of Service and Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorsManager.rafeeqYellow.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC49F47),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white70),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A170F),
            hintText: "Enter your $label",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC49F47), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}