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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

          final contentPadHorizontal = isMobile ? 24.0 : (isTablet ? 32.0 : 40.0);
          final contentPadTop = isMobile ? 26.0 : (isTablet ? 30.0 : 34.0);
          final contentPadBottom = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
          final welcomeExtraTopResolved =
              isTablet ? 14.0 : (isDesktop ? 16.0 : 12.0);
          final newHereBottomPad =
              isTablet ? 22.0 : (isDesktop ? 24.0 : 18.0);

          final formPadding = EdgeInsets.fromLTRB(
            contentPadHorizontal,
            contentPadTop,
            contentPadHorizontal,
            contentPadBottom,
          );

          final gapAfterTitle = isTablet ? 34.0 : (isDesktop ? 32.0 : 28.0);
          final gapBetweenFields = isTablet ? 24.0 : 22.0;
          final gapBeforeOrb = isTablet ? 34.0 : 32.0;

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
                                        if (state is EmailNotVerified) {
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
                                                'Welcome back, ${state.user.email ?? "User"}!',
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
                                        const orbitOrbY = 0.64;
                                        return AuthGlassPanel(
                                          orbitOrbCenterY: orbitOrbY,
                                          padding: formPadding,
                                          child: Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          SizedBox(
                                                            height:
                                                                welcomeExtraTopResolved,
                                                          ),
                                                          Text(
                                                            'Welcome',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize:
                                                                  isMobile
                                                                      ? 40
                                                                      : (isTablet
                                                                          ? 44
                                                                          : 46),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color:
                                                                  SculptedLoginTokens
                                                                      .offWhite,
                                                              height: 1.05,
                                                              letterSpacing:
                                                                  -0.8,
                                                              shadows:
                                                                  _titleShadows(),
                                                            ),
                                                          ),
                                                          Text(
                                                            'back',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize:
                                                                  isMobile
                                                                      ? 40
                                                                      : (isTablet
                                                                          ? 44
                                                                          : 46),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  SculptedLoginTokens
                                                                      .amber,
                                                              height: 1.05,
                                                              letterSpacing:
                                                                  -0.5,
                                                              shadows:
                                                                  _titleShadows(),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                gapAfterTitle,
                                                          ),
                                                          Text(
                                                            'Continue to '
                                                            'your workspace',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize:
                                                                  isMobile
                                                                      ? 15
                                                                      : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  SculptedLoginTokens
                                                                      .offWhite
                                                                      .withValues(
                                                                alpha: 0.72,
                                                              ),
                                                              height: 1.45,
                                                              shadows:
                                                                  _titleShadows(),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                gapBetweenFields +
                                                                    8,
                                                          ),
                                                          OrbitTextField(
                                                            controller:
                                                                _emailController,
                                                            label:
                                                                'Email address',
                                                            hint:
                                                                'hello@4ideasapp.com',
                                                            leadingIcon: Icons
                                                                .mail_outline_rounded,
                                                            keyboardType:
                                                                TextInputType
                                                                    .emailAddress,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty) {
                                                                return 'Please enter your email';
                                                              }
                                                              if (!value.contains(
                                                                  '@')) {
                                                                return 'Please enter a valid email';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                gapBetweenFields,
                                                          ),
                                                          OrbitTextField(
                                                            controller:
                                                                _passwordController,
                                                            label: 'Password',
                                                            hint: 'Password',
                                                            leadingIcon: Icons
                                                                .lock_outline_rounded,
                                                            obscureText:
                                                                _obscurePassword,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            trailing:
                                                                IconButton(
                                                              style: IconButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                                visualDensity:
                                                                    VisualDensity
                                                                        .compact,
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
                                                                        alpha:
                                                                            0.55),
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
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Please enter your password';
                                                              }
                                                              if (value.length <
                                                                  6) {
                                                                return 'Password must be at least 6 characters';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: TextButton(
                                                              onPressed: () =>
                                                                  context.push(
                                                                AppRoutes
                                                                    .forgotPassword,
                                                              ),
                                                              child: Text(
                                                                'Forgot password',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      SculptedLoginTokens
                                                                          .amber,
                                                                  letterSpacing:
                                                                      0.15,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                gapBeforeOrb,
                                                          ),
                                                          Center(
                                                            child:
                                                                OrbContinueButton(
                                                              isLoading:
                                                                  loading,
                                                              onPressed: loading
                                                                  ? null
                                                                  : () {
                                                                      final valid = _formKey
                                                                              .currentState
                                                                              ?.validate() ??
                                                                          false;
                                                                      if (!valid) {
                                                                        return;
                                                                      }
                                                                      context
                                                                          .read<
                                                                              AuthBloc>()
                                                                          .add(
                                                                            AuthLoginRequested(
                                                                              email: _emailController.text.trim(),
                                                                              password: _passwordController.text,
                                                                            ),
                                                                          );
                                                                    },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: isTablet
                                                                ? 34
                                                                : 30,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Divider(
                                                                  color: SculptedLoginTokens
                                                                      .offWhite
                                                                      .withValues(
                                                                          alpha:
                                                                              0.14),
                                                                  thickness: 1,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      14,
                                                                ),
                                                                child: Text(
                                                                  'Or with',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        12,
                                                                    color: SculptedLoginTokens
                                                                        .offWhite
                                                                        .withValues(
                                                                            alpha:
                                                                                0.45),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Divider(
                                                                  color: SculptedLoginTokens
                                                                      .offWhite
                                                                      .withValues(
                                                                          alpha:
                                                                              0.14),
                                                                  thickness: 1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: isTablet
                                                                ? 20
                                                                : 18,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              _SocialOrb(
                                                                size: isMobile
                                                                    ? 48
                                                                    : 52,
                                                                onTap: loading
                                                                    ? null
                                                                    : () {
                                                                        context
                                                                            .read<AuthBloc>()
                                                                            .add(
                                                                              const AuthSignInWithGoogleRequested(),
                                                                            );
                                                                      },
                                                                child:
                                                                    Image.asset(
                                                                  'assets/platforms/google.png',
                                                                  width:
                                                                      isMobile
                                                                          ? 26
                                                                          : 28,
                                                                  errorBuilder:
                                                                      (
                                                                    c,
                                                                    e,
                                                                    s,
                                                                  ) {
                                                                    return Icon(
                                                                      Icons
                                                                          .g_mobiledata_rounded,
                                                                      size: 28,
                                                                      color: SculptedLoginTokens
                                                                          .offWhite,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: isMobile
                                                                    ? 20
                                                                    : 24,
                                                              ),
                                                              _SocialOrb(
                                                                size: isMobile
                                                                    ? 48
                                                                    : 52,
                                                                onTap: loading
                                                                    ? null
                                                                    : () {
                                                                        context
                                                                            .read<AuthBloc>()
                                                                            .add(
                                                                              const AuthSignInWithAppleRequested(),
                                                                            );
                                                                      },
                                                                child:
                                                                    Image.asset(
                                                                  'assets/platforms/apple.png',
                                                                  width:
                                                                      isMobile
                                                                          ? 24
                                                                          : 26,
                                                                  errorBuilder:
                                                                      (
                                                                    c,
                                                                    e,
                                                                    s,
                                                                  ) {
                                                                    return Icon(
                                                                      Icons
                                                                          .apple,
                                                                      size: isMobile
                                                                          ? 32
                                                                          : 34,
                                                                      color: SculptedLoginTokens
                                                                          .offWhite,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: isTablet
                                                                ? 26
                                                                : 22,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              bottom:
                                                                  newHereBottomPad,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'New here?',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        14,
                                                                    color: SculptedLoginTokens
                                                                        .offWhite
                                                                        .withValues(
                                                                      alpha:
                                                                          0.55,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      context
                                                                          .pushReplacement(
                                                                    AppRoutes
                                                                        .signUp,
                                                                  ),
                                                                  child: Text(
                                                                    'Create '
                                                                    'account',
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: SculptedLoginTokens
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

class _SocialOrb extends StatelessWidget {
  const _SocialOrb({
    required this.size,
    required this.child,
    this.onTap,
  });

  final double size;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SculptedLoginTokens.graphiteGlass.withValues(alpha: 0.75),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
