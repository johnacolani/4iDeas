import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        title: Text(
          'Login',
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
              if (state is EmailNotVerified) {
                context.pushReplacement(
                  AppRoutes.emailVerification,
                  extra: state.user.email ?? _emailController.text.trim(),
                );
              } else if (state is Authenticated) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Welcome back, ${state.user.email ?? "User"}!'),
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
              return Padding(
                padding: FrostedAppBar.contentPaddingUnderAppBar(context),
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
                              decoration: ColorManager.loginAuthCardDecoration(borderRadius: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.albertSans(
                                      color: ColorManager.textPrimary,
                                      fontSize: isMobile ? 28 : 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Text(
                                    'Sign in to continue',
                                    style: TextStyle(
                                      color: ColorManager.primaryTeal,
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
                                    accentColor: ColorManager.primaryTeal,
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
                                    accentColor: ColorManager.primaryTeal,
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
                                  SizedBox(height: he * 0.01),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.push(AppRoutes.forgotPassword),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: ColorManager.primaryTeal,
                                          fontSize: isMobile ? 14 : 15,
                                        ),
                                      ),
                                    ),
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
                                                      AuthLoginRequested(
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
                                              'Login',
                                              style: GoogleFonts.albertSans(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: he * 0.025),
                                  // Divider with "or" text
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: ColorManager.containerBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: ColorManager.textMuted,
                                            fontSize: isMobile ? 14 : 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: ColorManager.containerBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: he * 0.025),
                                  // Social Login Logos in a Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google Logo
                                      GestureDetector(
                                        onTap: state is AuthLoading
                                            ? null
                                            : () {
                                                context.read<AuthBloc>().add(
                                                      const AuthSignInWithGoogleRequested(),
                                                    );
                                              },
                                        child: Image.asset(
                                          'assets/google.png',
                                          width: isMobile ? 50 : 60,
                                          height: isMobile ? 50 : 60,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.g_mobiledata,
                                              size: 32,
                                              color: Colors.blue,
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 20 : 24),
                                      // Apple Logo
                                      GestureDetector(
                                        onTap: state is AuthLoading
                                            ? null
                                            : () {
                                                context.read<AuthBloc>().add(
                                                      const AuthSignInWithAppleRequested(),
                                                    );
                                              },
                                        child: Image.asset(
                                          'assets/apple.png',
                                          width: isMobile ? 50 : 60,
                                          height: isMobile ? 50 : 60,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.apple,
                                              size: 32,
                                              color: ColorManager.textPrimary,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: ColorManager.textSecondary,
                                          fontSize: isMobile ? 14 : 15,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pushReplacement(AppRoutes.signUp),
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: ColorManager.primaryTeal,
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






