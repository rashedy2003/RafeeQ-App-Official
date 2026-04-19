import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';

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

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedNationality;
  bool isPasswordObscured = true;

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
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return BlocProvider(
      create: (context) => RegisterCubit(RegisterRepo(RegisterApiService())),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              Navigator.pushNamed(context, Routes.loginScreen);
            } else if (state is RegisterError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // خلفية ثابتة للأداء العالي
                Positioned.fill(
                  child: Image.asset("assets/images/background.png", fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.65)),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              Image.asset("assets/images/Radeqcenter.png", height: screenHeight * 0.15)
                                  .animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

                              const SizedBox(height: 10),

                              // جملة الترحيب البريميوم الموحدة
                              _buildPremiumWelcome(),

                              const SizedBox(height: 35),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: firstNameController,
                                      label: 'FIRST NAME',
                                      hint: 'Enter first name',
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: lastNameController,
                                      label: 'LAST NAME',
                                      hint: 'Enter last name',
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: userNameController,
                                label: 'USERNAME',
                                hint: 'Choose a unique username',
                              ).animate().fadeIn(delay: 200.ms),

                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: emailController,
                                label: 'EMAIL ADDRESS',
                                hint: 'yourname@domain.com',
                                keyboardType: TextInputType.emailAddress,
                                isEmail: true,
                              ).animate().fadeIn(delay: 300.ms),

                              const SizedBox(height: 15),

                              _buildCountryPickerField().animate().fadeIn(delay: 400.ms),

                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: passwordController,
                                label: 'PASSWORD',
                                hint: 'Enter your password',
                                isPassword: true,
                                isObscured: isPasswordObscured,
                                onSuffixIconTap: () => setState(() => isPasswordObscured = !isPasswordObscured),
                              ).animate().fadeIn(delay: 500.ms),

                              const SizedBox(height: 35),

                              _buildSignUpButton(state, context),

                              const SizedBox(height: 25),
                              _buildLoginRedirect(context).animate().fadeIn(delay: 700.ms),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ميثود الترحيب البريميوم الموحدة والمحسنة
  Widget _buildPremiumWelcome() {
    return Text(
      "Join the RafeeQ journey",
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 700.ms)
        .slideY(begin: 0.1, end: 0, duration: 700.ms, curve: Curves.easeOutCubic)
        .shimmer(
      delay: 800.ms,
      duration: 2.5.seconds,
      colors: [
        Colors.white,
        const Color(0xFFF1E4C1),
        ColorsManager.rafeeqYellow,
        const Color(0xFFF1E4C1),
        Colors.white,
      ],
      angle: -0.5,
      size: 0.4,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    bool? isObscured,
    VoidCallback? onSuffixIconTap,
    bool isEmail = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  $label",
            style: GoogleFonts.montserrat(
                color: ColorsManager.rafeeqYellow.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? (isObscured ?? true) : false,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
          validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isObscured! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white38, size: 20,
              ),
              onPressed: onSuffixIconTap,
            )
                : null,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ColorsManager.rafeeqYellow, width: 1.2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.redAccent, width: 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  NATIONALITY",
            style: GoogleFonts.montserrat(
                color: ColorsManager.rafeeqYellow.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                backgroundColor: const Color(0xFF1A170F),
                textStyle: GoogleFonts.montserrat(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              onSelect: (Country country) => setState(() => selectedNationality = country.name),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedNationality ?? "Select Country",
                  style: GoogleFonts.montserrat(
                    color: selectedNationality == null ? Colors.white24 : Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.public, color: ColorsManager.rafeeqYellow, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(RegisterState state, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: state is RegisterLoading ? null : () => _validateAndSubmit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.rafeeqYellow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: state is RegisterLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Text("CREATE ACCOUNT",
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.1)),
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(delay: 3.seconds, duration: 2.seconds, color: Colors.white30);
  }

  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ",
            style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 13)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, Routes.loginScreen),
          child: Text("Login",
              style: GoogleFonts.montserrat(
                  color: ColorsManager.rafeeqYellow, fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ],
    );
  }

  void _validateAndSubmit(BuildContext context) {
    if (_formKey.currentState!.validate() && selectedNationality != null) {
      context.read<RegisterCubit>().emitRegisterStates(
        RegisterRequestBody(
          userName: userNameController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          nationality: selectedNationality!,
          preferredLanguage: "English",
        ),
      );
    } else if (selectedNationality == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Nationality")));
    }
  }
}