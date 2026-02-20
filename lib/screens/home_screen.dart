import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/helper/sliding_menu.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/features/auth/presentation/screens/login_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/profile_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/signup_screen.dart';
import 'package:four_ideas/screens/web_screen.dart';

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
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 4.0 : (isTablet ? 24.0 : 32.0),
            vertical: isMobile ? 12.0 : (isTablet ? 24.0 : 28.0),
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
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
                          color: ColorManager.orange.withValues(alpha: 0.5),
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
                          color: Colors.white,
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
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileScreen(),
                                        ),
                                      );
                                    },
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
                                        fontSize: wi < 400 ? 8 : 9,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: ColorManager.blue,
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
                                                  wi < 400 ? 8 * 1.3 : 9 * 1.3,
                                              fontWeight: FontWeight.bold,
                                              color: ColorManager.orange,
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
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileScreen(),
                                        ),
                                      );
                                    },
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
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: ColorManager.blue,
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
                                              color: ColorManager.orange,
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
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
                                                wi < 400 ? 8 * 1.3 : 9 * 1.3,
                                            color: ColorManager.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SelectableText(
                                        ' / ',
                                        style: TextStyle(
                                          fontSize:
                                              wi < 400 ? 8 * 1.3 : 9 * 1.3,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
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
                                                wi < 400 ? 8 * 1.3 : 9 * 1.3,
                                            color: ColorManager.orange,
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
                                        color: ColorManager.blue,
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
                                                  wi < 400 ? 8 * 1.3 : 9 * 1.3,
                                              fontWeight: FontWeight.bold,
                                              color: ColorManager.orange,
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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
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
                                            color: ColorManager.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SelectableText(
                                        ' / ',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
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
                                            color: ColorManager.orange,
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
                                        color: ColorManager.blue,
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
                                              color: ColorManager.orange,
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
      ),
    );
  }
}
