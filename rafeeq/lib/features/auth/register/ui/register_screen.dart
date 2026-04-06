import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';

// استبدل المسارات دي بالمسارات الحقيقية في مشروعك
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/theme.dart';
import '../logic/register_cubit.dart';
import '../logic/register_state.dart';
import '../data/models/register_request_body.dart';
import '../register_api_service.dart';
import '../register_repo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedNationality;
  String? selectedLanguage;
  final List<String> famousLanguages = ['Arabic', 'English', 'French', 'Spanish', 'German'];

  @override
  void dispose() {
    userNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // تمرير الـ Repo والـ Service مباشرة للـ Cubit
      create: (context) => RegisterCubit(RegisterRepo(RegisterApiService())),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: ColorsManager.black,
            body: BlocConsumer<RegisterCubit, RegisterState>(
              listener: (context, state) {
                if (state is RegisterSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Success! Please check your email."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushNamed(context, Routes.loginScreen);
                } else if (state is RegisterError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/background.png",
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Blur Effect
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: ColorsManager.black.withOpacity(0.4)),
                      ),
                    ),

                    // Main Content
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Image.asset("assets/images/Radeqcenter.png", height: 120),
                              const Text(
                                "Discover the wonders of Egypt",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsManager.rafeeqYellow,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Name Row
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(controller: firstNameController, label: 'First Name')),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildTextField(controller: lastNameController, label: 'Last Name')),
                                ],
                              ),
                              const SizedBox(height: 15),

                              _buildTextField(controller: userNameController, label: 'Username'),
                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: emailController,
                                label: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                                isEmail: true,
                              ),
                              const SizedBox(height: 15),

                              // Nationality & Language
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: _buildCountryPickerField()),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Language',
                                      value: selectedLanguage,
                                      items: famousLanguages,
                                      onChanged: (val) => setState(() => selectedLanguage = val),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: passwordController,
                                label: 'Password',
                                isPassword: true,
                              ),

                              const SizedBox(height: 35),

                              // SIGN UP Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: state is RegisterLoading
                                      ? null
                                      : () => _validateAndSubmit(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorsManager.rafeeqYellow,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    disabledBackgroundColor: ColorsManager.rafeeqYellow.withOpacity(0.5),
                                  ),
                                  child: state is RegisterLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: ColorsManager.black, strokeWidth: 2),
                                  )
                                      : const Text(
                                    "SIGN UP",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorsManager.black),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              _buildLoginRedirect(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _validateAndSubmit(BuildContext context) {
    debugPrint("🔍 Register: Starting Validation...");

    if (_formKey.currentState!.validate()) {
      if (selectedNationality == null || selectedLanguage == null) {
        debugPrint("⚠️ Register: Nationality or Language not selected");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select Nationality & Language")),
        );
        return;
      }

      debugPrint("✅ Register: Validation Passed. Sending Data to Cubit...");

      context.read<RegisterCubit>().emitRegisterStates(
        RegisterRequestBody(
          userName: userNameController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          nationality: selectedNationality!,
          preferredLanguage: selectedLanguage!,
        ),
      );
    } else {
      debugPrint("❌ Register: Form Validation Failed");
    }
  }

  // --- Helper Widgets ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool isEmail = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: ColorsManager.rafeeqYellow, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: ColorsManager.white, fontSize: 14),
          validator: (value) {
            if (value == null || value.isEmpty) return "Required";
            if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Invalid Email";
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A170F).withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorsManager.rafeeqYellow, width: 1.2),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nationality", style: TextStyle(color: ColorsManager.rafeeqYellow, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                backgroundColor: const Color(0xFF1A170F),
                textStyle: const TextStyle(color: ColorsManager.white),
                borderRadius: BorderRadius.circular(20),
              ),
              onSelect: (Country country) => setState(() => selectedNationality = country.name),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF1A170F).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsManager.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedNationality ?? "Select",
                    style: TextStyle(
                      color: selectedNationality == null ? ColorsManager.white.withOpacity(0.2) : ColorsManager.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.public, color: ColorsManager.rafeeqYellow, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: ColorsManager.rafeeqYellow, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1A170F),
          icon: const Icon(Icons.expand_more, color: ColorsManager.rafeeqYellow),
          style: const TextStyle(color: ColorsManager.white, fontSize: 14),
          validator: (val) => val == null ? "Required" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A170F).withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ColorsManager.rafeeqYellow)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ", style: TextStyle(color: ColorsManager.white, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.loginScreen),
          child: const Text("Login", style: TextStyle(color: ColorsManager.rafeeqYellow, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}