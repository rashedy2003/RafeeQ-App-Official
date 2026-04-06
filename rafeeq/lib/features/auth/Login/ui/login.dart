import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(LoginRepo(LoginApiService())),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            body: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  // طباعة التوكن في الكونسول للتأكد
                  debugPrint("🎯 Login Success! Token: ${state.loginResponse.token}");
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
                    Positioned.fill(child: Image.asset("assets/images/background.png", fit: BoxFit.cover)),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(color: Colors.black.withOpacity(0.2)),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Image.asset("assets/images/Radeqcenter.png", height: 200),
                              Text("Welcome back, Traveler",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorsManager.rafeeqYellow)),
                              const SizedBox(height: 40),
                              _buildTextField(
                                controller: emailController,
                                label: 'Email Address',
                                validator: (value) => (value == null || value.isEmpty) ? "Email is required" : null,
                              ),
                              const SizedBox(height: 30),
                              _buildTextField(
                                controller: passwordController,
                                label: 'Password',
                                isPassword: true,
                                validator: (value) => (value == null || value.isEmpty) ? "Password is required" : null,
                              ),
                              const SizedBox(height: 50),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: state is LoginLoading ? null : () => _validateAndSubmit(context),
                                  style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.rafeeqYellow),
                                  child: state is LoginLoading
                                      ? const CircularProgressIndicator(color: Colors.black)
                                      : const Text("SIGN IN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildSignUpRedirect(context),
                              const Spacer(),
                              Text("2026 RAFEQ TRAVEL EGYPT\nENCRYPTED SECURE ACCESS ONLY",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: ColorsManager.rafeeqYellow.withOpacity(0.8))),
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
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().emitLoginStates(
        LoginRequestBody(email: emailController.text.trim(), password: passwordController.text),
      );
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isPassword = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFC49F47), fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          style: const TextStyle(color: Colors.white70),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A170F),
            hintText: "Enter your $label",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC49F47))),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account ? ", style: TextStyle(color: ColorsManager.rafeeqYellow)),
        TextButton(onPressed: () => Navigator.pushNamed(context, Routes.registerScreen), child: const Text(" Sign Up", style: TextStyle(color: ColorsManager.rafeeqYellow, fontWeight: FontWeight.bold, fontSize: 18))),
      ],
    );
  }
}