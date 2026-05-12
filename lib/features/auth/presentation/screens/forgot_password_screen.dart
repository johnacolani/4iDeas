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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
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
          final gapAfterTitle = isTablet ? 28.0 : 26.0;
          final gapBeforeOrb = isTablet ? 32.0 : 28.0;

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
                      children: [
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
                                        if (state is PasswordResetSent) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(state.message),
                                              backgroundColor:
                                                  const Color(0xFF1B7F4B),
                                            ),
                                          );
                                          context.pop();
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
                                          orbitOrbCenterY: 0.52,
                                          padding: formPadding,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(height: titleTop),
                                                Text(
                                                  'Reset',
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
                                                  'password',
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
                                                  'Enter your email and we will send you a link to reset your password.',
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
                                                SizedBox(height: gapAfterTitle),
                                                OrbitTextField(
                                                  controller: _emailController,
                                                  label: 'Email',
                                                  hint: 'Enter your email',
                                                  leadingIcon:
                                                      Icons.mail_outline_rounded,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.done,
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
                                                SizedBox(height: gapBeforeOrb),
                                                Center(
                                                  child: OrbContinueButton(
                                                    isLoading: loading,
                                                    onPressed: loading
                                                        ? null
                                                        : () {
                                                            if (!(_formKey
                                                                    .currentState
                                                                    ?.validate() ??
                                                                false)) {
                                                              return;
                                                            }
                                                            context.read<AuthBloc>().add(
                                                                  AuthForgotPasswordRequested(
                                                                    email:
                                                                        _emailController
                                                                            .text
                                                                            .trim(),
                                                                  ),
                                                                );
                                                          },
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
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
