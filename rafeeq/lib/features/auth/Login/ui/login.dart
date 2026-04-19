import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/theme.dart';
import '../logic/login_cubit.dart';
import '../logic/login_state.dart';
import '../data/models/login_request_body.dart';
import '../data/repos/login_repo.dart';
import '../data/models/login_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordObscured = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return BlocProvider(
      create: (context) => LoginCubit(LoginRepo(LoginApiService())),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.pushNamedAndRemoveUntil(context, Routes.homeScreen, (route) => false);
            } else if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset("assets/images/background.png", fit: BoxFit.cover)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.07, 1.07), duration: 15.seconds),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 30),

                                    Image.asset("assets/images/Radeqcenter.png", height: screenHeight * 0.2)
                                        .animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),

                                    const SizedBox(height: 15),

                                    // الجزء البريميوم: الترحيب بخط Montserrat
                                    _buildPremiumWelcome(),

                                    const SizedBox(height: 45),

                                    _buildTextField(
                                      controller: emailController,
                                      label: 'EMAIL ADDRESS',
                                      hint: 'name@example.com',
                                      icon: Icons.email_outlined,
                                      validator: (value) => (value == null || value.isEmpty) ? "Email is required" : null,
                                    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

                                    const SizedBox(height: 20),

                                    _buildTextField(
                                      controller: passwordController,
                                      label: 'PASSWORD',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      isObscured: isPasswordObscured,
                                      onSuffixIconTap: () {
                                        setState(() {
                                          isPasswordObscured = !isPasswordObscured;
                                        });
                                      },
                                      validator: (value) => (value == null || value.isEmpty) ? "Password is required" : null,
                                    ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1),

                                    const SizedBox(height: 40),

                                    _buildSignInButton(state, context),

                                    const SizedBox(height: 25),

                                    _buildSignUpRedirect(context).animate().fadeIn(delay: 1200.ms),

                                    const Spacer(),

                                    Text("2026 RAFEQ TRAVEL EGYPT\nSECURE ENCRYPTED ACCESS",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat( // توحيد الخط
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: ColorsManager.rafeeqYellow.withOpacity(0.4),
                                            letterSpacing: 1.5)),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPremiumWelcome() {
    return Text(
      "Welcome back to RafeeQ",
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat( // خط بريميوم جداً
        fontSize: 18,
        fontWeight: FontWeight.w500, // Semi-Bold ليكون أوضح وفخم
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 1.seconds)
        .slideY(begin: 0.1, end: 0, duration: 1.seconds, curve: Curves.easeOutCubic)
        .shimmer(
      delay: 1.seconds,
      duration: 3.seconds,
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
    required IconData icon,
    bool isPassword = false,
    bool? isObscured,
    VoidCallback? onSuffixIconTap,
    String? Function(String?)? validator,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? (isObscured ?? true) : false,
              validator: validator,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: ColorsManager.rafeeqYellow.withOpacity(0.5), size: 20),
                suffixIcon: isPassword
                    ? IconButton(
                  icon: Icon(
                    isObscured! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white24,
                    size: 20,
                  ),
                  onPressed: onSuffixIconTap,
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white12, fontSize: 13),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ColorsManager.rafeeqYellow, width: 1)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5))),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(LoginState state, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.rafeeqYellow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: state is LoginLoading ? null : () => _validateAndSubmit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.rafeeqYellow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: state is LoginLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Text("SIGN IN",
            style: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.1
            )),
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(delay: 4.seconds, duration: 2.seconds, color: Colors.white30);
  }

  Widget _buildSignUpRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w400)),
        TextButton(
            onPressed: () => Navigator.pushNamed(context, Routes.registerScreen),
            child: Text("Sign Up",
                style: GoogleFonts.montserrat(
                    color: ColorsManager.rafeeqYellow,
                    fontWeight: FontWeight.w800,
                    fontSize: 15
                ))),
      ],
    );
  }

  void _validateAndSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().emitLoginStates(
        LoginRequestBody(email: emailController.text.trim(), password: passwordController.text),
      );
    }
  }
}