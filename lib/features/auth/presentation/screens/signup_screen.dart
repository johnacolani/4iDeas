import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_router.dart';
import '../../../../helper/app_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_glass_panel.dart';
import '../widgets/orb_continue_button.dart';
import '../widgets/orbit_text_field.dart';
import '../widgets/sculpted_login_tokens.dart';

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
  final _scrollController = ScrollController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  static List<Shadow> _titleShadows() => [
        Shadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 14,
          offset: const Offset(0, 2),
        ),
        Shadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final isMobile = maxW < 600;
          final isTablet = maxW >= 600 && maxW < 900;
          final isDesktop = maxW >= 900;

          final panelMaxWidth = isDesktop
              ? 620.0
              : isTablet
                  ? 520.0
                  : (maxW - 32).clamp(300.0, 460.0);

          final contentPadHorizontal =
              isMobile ? 24.0 : (isTablet ? 32.0 : 40.0);
          final contentPadTop = isMobile ? 26.0 : (isTablet ? 30.0 : 34.0);
          final contentPadBottom = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
          final titleTop = isTablet ? 14.0 : (isDesktop ? 16.0 : 12.0);
          final gapAfterTitle = isTablet ? 32.0 : (isDesktop ? 30.0 : 26.0);
          final gapBetweenFields = isTablet ? 22.0 : 20.0;
          final gapBeforeOrb = isTablet ? 28.0 : 26.0;
          final bottomLinkPad = isTablet ? 20.0 : 18.0;

          final formPadding = EdgeInsets.fromLTRB(
            contentPadHorizontal,
            contentPadTop,
            contentPadHorizontal,
            contentPadBottom,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              const AppBackground(),
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFF090C0F).withValues(alpha: 0.52),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, safeConstraints) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16.0 : 24.0,
                                vertical: 12,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: math.max(
                                    0,
                                    safeConstraints.maxHeight - 28,
                                  ),
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: panelMaxWidth,
                                    ),
                                    child: BlocConsumer<AuthBloc, AuthState>(
                                      listener: (context, state) {
                                        if (state is EmailVerificationSent) {
                                          context.pushReplacement(
                                            AppRoutes.emailVerification,
                                            extra: _emailController.text.trim(),
                                          );
                                        } else if (state is EmailNotVerified) {
                                          context.pushReplacement(
                                            AppRoutes.emailVerification,
                                            extra: state.user.email ??
                                                _emailController.text.trim(),
                                          );
                                        } else if (state is Authenticated) {
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          context.go(AppRoutes.home);
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Account created successfully! '
                                                'Welcome, ${state.user.email ?? "User"}!',
                                              ),
                                              backgroundColor:
                                                  const Color(0xFF1B7F4B),
                                            ),
                                          );
                                        } else if (state is AuthError) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(state.message),
                                              backgroundColor:
                                                  SculptedLoginTokens.coral,
                                            ),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        final loading = state is AuthLoading;
                                        return AuthGlassPanel(
                                          orbitOrbCenterY: 0.58,
                                          padding: formPadding,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(height: titleTop),
                                                Text(
                                                  'Create',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize: isMobile
                                                        ? 38
                                                        : (isTablet ? 42 : 44),
                                                    fontWeight: FontWeight.w300,
                                                    color: SculptedLoginTokens
                                                        .offWhite,
                                                    height: 1.05,
                                                    letterSpacing: -0.8,
                                                    shadows: _titleShadows(),
                                                  ),
                                                ),
                                                Text(
                                                  'account',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize: isMobile
                                                        ? 38
                                                        : (isTablet ? 42 : 44),
                                                    fontWeight: FontWeight.w600,
                                                    color: SculptedLoginTokens
                                                        .amber,
                                                    height: 1.05,
                                                    letterSpacing: -0.5,
                                                    shadows: _titleShadows(),
                                                  ),
                                                ),
                                                SizedBox(height: gapAfterTitle),
                                                Text(
                                                  'Sign up to get started',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize:
                                                        isMobile ? 15 : 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: SculptedLoginTokens
                                                        .offWhite
                                                        .withValues(
                                                            alpha: 0.72),
                                                    height: 1.45,
                                                    shadows: _titleShadows(),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: gapBetweenFields +
                                                        8),
                                                OrbitTextField(
                                                  controller: _emailController,
                                                  label: 'Email',
                                                  hint: 'Enter your email',
                                                  leadingIcon:
                                                      Icons.mail_outline_rounded,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Please enter your email';
                                                    }
                                                    if (!value.contains('@')) {
                                                      return 'Please enter a valid email';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(
                                                    height: gapBetweenFields),
                                                OrbitTextField(
                                                  controller:
                                                      _passwordController,
                                                  label: 'Password',
                                                  hint: 'Enter your password',
                                                  leadingIcon:
                                                      Icons.lock_outline_rounded,
                                                  obscureText: _obscurePassword,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  trailing: IconButton(
                                                    style: IconButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                    icon: Icon(
                                                      _obscurePassword
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      color: SculptedLoginTokens
                                                          .offWhite
                                                          .withValues(
                                                              alpha: 0.55),
                                                      size: 22,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter your password';
                                                    }
                                                    if (value.length < 6) {
                                                      return 'Password must be at least 6 characters';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(
                                                    height: gapBetweenFields),
                                                OrbitTextField(
                                                  controller:
                                                      _confirmPasswordController,
                                                  label: 'Confirm Password',
                                                  hint: 'Confirm your password',
                                                  leadingIcon:
                                                      Icons.lock_outline_rounded,
                                                  obscureText:
                                                      _obscureConfirmPassword,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  trailing: IconButton(
                                                    style: IconButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                    icon: Icon(
                                                      _obscureConfirmPassword
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      color: SculptedLoginTokens
                                                          .offWhite
                                                          .withValues(
                                                              alpha: 0.55),
                                                      size: 22,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscureConfirmPassword =
                                                            !_obscureConfirmPassword;
                                                      });
                                                    },
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please confirm your password';
                                                    }
                                                    if (value !=
                                                        _passwordController
                                                            .text) {
                                                      return 'Passwords do not match';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: gapBeforeOrb),
                                                Center(
                                                  child: OrbContinueButton(
                                                    isLoading: loading,
                                                    onPressed: loading
                                                        ? null
                                                        : () {
                                                            final valid =
                                                                _formKey
                                                                        .currentState
                                                                        ?.validate() ??
                                                                    false;
                                                            if (!valid) return;
                                                            context.read<AuthBloc>().add(
                                                                  AuthSignUpRequested(
                                                                    email:
                                                                        _emailController
                                                                            .text
                                                                            .trim(),
                                                                    password:
                                                                        _passwordController
                                                                            .text,
                                                                  ),
                                                                );
                                                          },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 24,
                                                    bottom: bottomLinkPad,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Already have an account? ',
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: isMobile
                                                              ? 14
                                                              : 15,
                                                          color: SculptedLoginTokens
                                                              .offWhite
                                                              .withValues(
                                                                  alpha: 0.55),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            context
                                                                .pushReplacement(
                                                          AppRoutes.login,
                                                        ),
                                                        child: Text(
                                                          'Login',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: isMobile
                                                                ? 14
                                                                : 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                SculptedLoginTokens
                                                                    .amber,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 4,
                          top: 4,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: SculptedLoginTokens.offWhite
                                  .withValues(alpha: 0.90),
                              size: 20,
                            ),
                            onPressed: () => _onBack(context),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
