import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userEmail;
  
  const EmailVerificationScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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
          'Verify Email',
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
              if (state is Authenticated) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email verified successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is EmailVerificationSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
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
                        maxWidth: isMobile ? double.infinity : 500,
                      ),
                      child: Container(
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
                              Icons.mark_email_read,
                              size: 80,
                              color: ColorManager.orange,
                            ),
                            SizedBox(height: he * 0.03),
                            Text(
                              'Verify Your Email',
                              style: GoogleFonts.albertSans(
                                color: Colors.white,
                                fontSize: isMobile ? 28 : 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: he * 0.02),
                            Text(
                              'We\'ve sent a verification email to:',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: isMobile ? 15 : 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: he * 0.01),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorManager.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.userEmail,
                                style: TextStyle(
                                  color: ColorManager.blue,
                                  fontSize: isMobile ? 16 : 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: he * 0.03),
                            Text(
                              'Please check your email and click on the verification link to verify your account.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: isMobile ? 15 : 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: he * 0.03),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                              const ReloadUserRequested(),
                                            );
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
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh),
                                          SizedBox(width: 8),
                                          Text(
                                            'I\'ve Verified My Email',
                                            style: GoogleFonts.albertSans(
                                              fontSize: isMobile ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(height: he * 0.02),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                              const ResendEmailVerificationRequested(),
                                            );
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColorManager.blue,
                                  side: BorderSide(
                                    color: ColorManager.blue,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.email_outlined),
                                    SizedBox(width: 8),
                                    Text(
                                      'Resend Verification Email',
                                      style: GoogleFonts.albertSans(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: he * 0.02),
                            Text(
                              'Note: The verification link may take a few minutes to arrive. Please check your spam folder if you don\'t see it.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: isMobile ? 12 : 13,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
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
}

