import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber[100]),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Forgot Password',
          style: GoogleFonts.albertSans(
            color: Colors.white,
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
              if (state is PasswordResetSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
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
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(
                                    Icons.lock_reset,
                                    size: 64,
                                    color: ColorManager.orange,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Text(
                                    'Reset Password',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: isMobile ? 28 : 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.02),
                                  Text(
                                    'Enter your email address and we will send you a link to reset your password.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: isMobile ? 15 : 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.03),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 17),
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                                      labelStyle: TextStyle(color: ColorManager.orange),
                                      prefixIcon: Icon(Icons.email_outlined, color: ColorManager.orange),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: ColorManager.orange, width: 2),
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
                                  ),
                                  SizedBox(height: he * 0.03),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!.validate()) {
                                                context.read<AuthBloc>().add(
                                                      AuthForgotPasswordRequested(
                                                        email: _emailController.text.trim(),
                                                      ),
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorManager.orange,
                                        foregroundColor: Colors.white,
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
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Send Reset Link',
                                              style: GoogleFonts.albertSans(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

