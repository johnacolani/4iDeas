import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../../../../app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        backgroundColor: ColorManager.accentGold,
        title: Text(
          'Sign Up',
          style: GoogleFonts.albertSans(
            color: ColorManager.backgroundDark,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is EmailVerificationSent) {
                context.pushReplacement(
                  AppRoutes.emailVerification,
                  extra: _emailController.text.trim(),
                );
              } else if (state is EmailNotVerified) {
                context.pushReplacement(
                  AppRoutes.emailVerification,
                  extra: state.user.email ?? _emailController.text.trim(),
                );
              } else if (state is Authenticated) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account created successfully! Welcome, ${state.user.email ?? "User"}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Center(
                  child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24.0 : 32.0,
                          vertical: 20.0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 400,
                        ),
                        child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isMobile ? 20 : 24),
                              decoration: ColorManager.signUpAuthCardDecoration(borderRadius: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: GoogleFonts.albertSans(
                                      color: ColorManager.textPrimary,
                                      fontSize: isMobile ? 28 : 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Text(
                                    'Sign up to get started',
                                    style: TextStyle(
                                      color: ColorManager.secondaryPurple,
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.03),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'Enter your email',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    accentColor: ColorManager.secondaryPurple,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    obscureText: _obscurePassword,
                                    prefixIcon: Icons.lock_outline,
                                    accentColor: ColorManager.secondaryPurple,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: ColorManager.textMuted,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    hint: 'Confirm your password',
                                    obscureText: _obscureConfirmPassword,
                                    prefixIcon: Icons.lock_outline,
                                    accentColor: ColorManager.secondaryPurple,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: ColorManager.textMuted,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!.validate()) {
                                                context.read<AuthBloc>().add(
                                                      AuthSignUpRequested(
                                                        email: _emailController.text.trim(),
                                                        password: _passwordController.text,
                                                      ),
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorManager.accentGold,
                                        foregroundColor: ColorManager.backgroundDark,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: state is AuthLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  ColorManager.backgroundDark,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Sign Up',
                                              style: GoogleFonts.albertSans(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          color: ColorManager.textSecondary,
                                          fontSize: isMobile ? 14 : 15,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pushReplacement(AppRoutes.login),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: ColorManager.secondaryPurple,
                                            fontSize: isMobile ? 14 : 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color accentColor,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: ColorManager.textPrimary, fontSize: isMobile ? 16 : 17),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: ColorManager.textMuted),
        labelStyle: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accentColor) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: ColorManager.containerSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.containerBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.containerBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

