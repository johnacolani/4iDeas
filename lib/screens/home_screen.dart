import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/helper/sliding_menu.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_event.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:go_router/go_router.dart';

import '../helper/app_background.dart';

import 'mobile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isMobile
          ? Stack(
              children: [
                const AppBackground(),
                const MobileScreen(),
                // Transparent container at top like appbar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: _buildTopContainer(isMobile, isTablet, wi),
                  ),
                ),
                const SlidingMenu(),
              ],
            )
          : Stack(
              children: [
                const AppBackground(),
                Positioned.fill(
                  child: const WebScreen(),
                ),
                // Transparent container at top like appbar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: _buildTopContainer(isMobile, isTablet, wi),
                  ),
                ),
                const SlidingMenu(),
              ],
            ),
    );
  }

  Widget _buildTopContainer(bool isMobile, bool isTablet, double wi) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HomeWarmColors.shellTop.withValues(alpha: 0.36),
                      HomeWarmColors.shellBottom.withValues(alpha: 0.24),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: HomeWarmColors.appBarBorderBottom,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HomeWarmColors.appBarShadow,
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(0.45, 0.5),
                    colors: [
                      Colors.white.withValues(alpha: 0.19),
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.26, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 4.0 : (isTablet ? 24.0 : 32.0),
                vertical: isMobile ? 12.0 : (isTablet ? 24.0 : 28.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Expanded(
                flex: isMobile ? 2 : 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: isMobile ? 4 : 8),
                    Container(
                      padding:
                          EdgeInsets.all(isMobile ? (wi < 400 ? 1.5 : 2) : 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HomeWarmColors.avatarRing,
                          width: isMobile ? (wi < 400 ? 1 : 1.5) : 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: isMobile
                            ? (wi < 400 ? wi * 0.03 : wi * 0.035)
                            : (isTablet ? wi * 0.035 : wi * 0.035),
                        backgroundImage:
                            const AssetImage('assets/images/logo.png'),
                      ),
                    ),
                    SizedBox(width: isMobile ? (wi < 400 ? 3 : 5) : 12),
                    Flexible(
                      child: SelectableText(
                        '4iDeas',
                        style: TextStyle(
                          fontSize: isMobile
                              ? (wi < 400 ? 14 : 16)
                              : (isTablet ? 18 : 22),
                          color: HomeWarmColors.textInk,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 16 : 24),
              // Auth buttons
              Expanded(
                flex: isMobile ? 1 : 1,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return isMobile
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.profile),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: wi < 400 ? 2 : 4,
                                            vertical: wi < 400 ? 2 : 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          state.user.email ?? 'User',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: wi < 400 ? 11 : 12,
                                            color: HomeWarmColors.textInk,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: wi < 400 ? 4 : 6),
                                      IconButton(
                                        onPressed: () {
                                          context.read<AuthBloc>().add(
                                                const AuthLogoutRequested(),
                                              );
                                        },
                                        icon: Icon(
                                          Icons.logout,
                                          size: wi < 400 ? 12 : 14,
                                          color: HomeWarmColors.iconLogout,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        tooltip: 'Sign Out',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: HomeWarmColors.iconLocation,
                                        size: wi < 400 ? wi * 0.025 : wi * 0.03,
                                      ),
                                      SizedBox(width: wi < 400 ? 3 : 6),
                                      Flexible(
                                        child: RichText(
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Based in: Richmond, VA',
                                             style: TextStyle(
                                              fontSize:
                                                  wi < 400 ? 11 : 12,
                                              fontWeight: FontWeight.bold,
                                              color: HomeWarmColors.textInk,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.profile),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          state.user.email ?? 'User',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 16,
                                            color: HomeWarmColors.textInk,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          context.read<AuthBloc>().add(
                                                const AuthLogoutRequested(),
                                              );
                                        },
                                        icon: Icon(
                                          Icons.logout,
                                          size: isTablet ? 18 : 20,
                                          color: HomeWarmColors.iconLogout,
                                        ),
                                        padding: EdgeInsets.all(4),
                                        constraints: BoxConstraints(),
                                        tooltip: 'Sign Out',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: HomeWarmColors.iconLocation,
                                        size:
                                            isTablet ? wi * 0.018 : wi * 0.018,
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: RichText(
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Based in: Richmond, VA',
                                            style: TextStyle(
                                              fontSize: isTablet ? 12 : 14,
                                              fontWeight: FontWeight.bold,
                                              color: HomeWarmColors.textInk,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    } else {
                      return isMobile
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.login),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: wi < 400 ? 4 : 6,
                                            vertical: wi < 400 ? 2 : 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize:
                                                wi < 400 ? 11 : 12,
                                            color: HomeWarmColors.linkLogin,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SelectableText(
                                        ' / ',
                                        style: TextStyle(
                                          fontSize:
                                              wi < 400 ? 11 : 12,
                                          color: HomeWarmColors.linkSlash,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.signUp),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: wi < 400 ? 4 : 6,
                                            vertical: wi < 400 ? 2 : 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize:
                                                wi < 400 ? 11 : 12,
                                            color: HomeWarmColors.linkSignUp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: HomeWarmColors.iconLocation,
                                        size: wi < 400 ? wi * 0.025 : wi * 0.03,
                                      ),
                                      SizedBox(width: wi < 400 ? 3 : 6),
                                      Flexible(
                                        child: RichText(
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Based in: Richmond, VA',
                                            style: TextStyle(
                                              fontSize:
                                                  wi < 400 ? 11 : 12,
                                              fontWeight: FontWeight.bold,
                                              color: HomeWarmColors.textInk,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.login),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 18,
                                            color: HomeWarmColors.linkLogin,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SelectableText(
                                        ' / ',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 18,
                                          color: HomeWarmColors.linkSlash,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.signUp),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 18,
                                            color: HomeWarmColors.linkSignUp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: HomeWarmColors.iconLocation,
                                        size:
                                            isTablet ? wi * 0.018 : wi * 0.018,
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: RichText(
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Based in: Richmond, VA',
                                            style: TextStyle(
                                              fontSize: isTablet ? 12 : 14,
                                              fontWeight: FontWeight.bold,
                                              color: HomeWarmColors.textInk,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    }
                  },
                ),
              ),
            ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
