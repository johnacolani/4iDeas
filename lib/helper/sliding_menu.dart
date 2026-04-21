import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/helper/menu_item.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/app_router.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';

class SlidingMenu extends StatefulWidget {
  const SlidingMenu({super.key});

  @override
  State<SlidingMenu> createState() => _SlidingMenuState();
}

class _SlidingMenuState extends State<SlidingMenu>
    with SingleTickerProviderStateMixin {
  static const List<Color> _drawerMenuAccents = <Color>[
    ColorManager.primaryTeal,
    ColorManager.secondaryPurple,
    ColorManager.accentCoral,
    ColorManager.accentGold,
  ];

  bool isSlideOpen = false;
  late AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeDrawerAndGo(String path) {
    setState(() {
      isSlideOpen = false;
      _animationController.reverse();
    });
    context.go(path);
  }

  Color _menuAccentAt(int index) => _drawerMenuAccents[index % _drawerMenuAccents.length];

  MenuItem _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return MenuItem(
      icon: icon,
      title: title,
      onPressed: onPressed,
      accentColor: _menuAccentAt(index),
      cardColor: const Color(0xFFFCF9F8),
    );
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    
    // Calculate drawer width responsively
    double drawerWidth;
    if (isMobile) {
      drawerWidth = wi * 0.65; // 65% of screen on mobile
    } else if (isTablet) {
      drawerWidth = 280; // Fixed 280px on tablet
    } else {
      drawerWidth = 300; // Fixed 300px on desktop
    }
    
    // Calculate drawer position - now on left side
    double closedPosition = -drawerWidth; // Hidden on the left
    double openPosition = 0; // Fully visible on the left

    return Stack(
      children: [
        // Tap to close overlay - appears only when drawer is fully open
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final progress = _animationController.value;
            return Positioned(
              left: drawerWidth,
              top: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: progress <= 0,
                child: GestureDetector(
                  onTap: () {
                    if (progress > 0) {
                      setState(() {
                        isSlideOpen = false;
                        _animationController.reverse();
                      });
                    }
                  },
                  child: Container(
                    color: isSlideOpen
                        ? const Color(0xFF000000)
                            .withValues(alpha: 0.08 * progress)
                        : Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
        // Drawer content
        AnimatedPositioned(
          left: isSlideOpen ? openPosition : closedPosition,
          duration: _animationController.duration ?? const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: HomeWarmColors.drawerSurfaceSolid,
                ),
                width: isMobile ? 2 : 3,
                height: he,
              ),
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: SizedBox(
                    height: he,
                    width: drawerWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color.alphaBlend(
                                HomeWarmColors.drawerNavyTint.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.025),
                              ),
                              border: Border(
                                top: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                                left: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                                right: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1,
                                ),
                                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  offset: const Offset(6, 0),
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
                                end: const Alignment(0.45, 0.52),
                                colors: [
                                  Colors.white.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.07),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.28, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 14.0 : 16.0),
                          child: Column(
                            children: [
                              SizedBox(height: isMobile ? 2.h : 3.h),
                              Container(
                                padding: EdgeInsets.all(isMobile ? 14 : 16),
                                decoration: BoxDecoration(
                                  color: HomeWarmColors.shellTop
                                      .withValues(alpha: 0.98),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: ColorManager.primaryTeal.withValues(alpha: 0.28),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorManager.primaryTeal.withValues(alpha: 0.10),
                                      blurRadius: 14,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ColorManager.accentCoral.withValues(alpha: 0.68),
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: isMobile ? 35 : 38,
                                        backgroundImage: const AssetImage('assets/images/logo.png'),
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 12 : 14),
                                    SelectableText(
                                      '4iDeas',
                                      style: TextStyle(
                                        fontSize: isMobile ? 22 : (isTablet ? 20 : 18),
                                        fontWeight: FontWeight.bold,
                                        color: ColorManager.textPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 12 : 14),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 14,
                                        vertical: isMobile ? 10 : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ColorManager.primaryTeal.withValues(alpha: 0.14),
                                            ColorManager.secondaryPurple.withValues(alpha: 0.10),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: ColorManager.primaryTeal.withValues(alpha: 0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          SelectableText(
                                            "Let's Talk! 🇺🇸",
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : (isTablet ? 13 : 12),
                                              color: ColorManager.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SelectableText(
                                            "804-774-9008",
                                            style: TextStyle(
                                              fontSize: isMobile ? 18 : (isTablet ? 17 : 16),
                                              color: ColorManager.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SelectableText(
                                            "info@4ideasapp.com",
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : (isTablet ? 13 : 12),
                                              color: ColorManager.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 4.0 : 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildMenuItem(
                                          index: 0,
                                          icon: Icons.design_services,
                                          title: 'Services',
                                          onPressed: () => _closeDrawerAndGo(AppRoutes.services),
                                        ),
                                        _buildMenuItem(
                                          index: 1,
                                          icon: Icons.people,
                                          title: 'About Us',
                                          onPressed: () => _closeDrawerAndGo(AppRoutes.about),
                                        ),
                                        _buildMenuItem(
                                          index: 2,
                                          icon: Icons.note,
                                          title: 'Portfolio',
                                          onPressed: () => _closeDrawerAndGo(AppRoutes.portfolio),
                                        ),
                                        _buildMenuItem(
                                          index: 3,
                                          icon: Icons.workspace_premium,
                                          title: 'Featured Case Studies',
                                          onPressed: () => _closeDrawerAndGo('${AppRoutes.portfolio}?section=featured'),
                                        ),
                                        _buildMenuItem(
                                          index: 4,
                                          icon: Icons.contrast,
                                          title: 'Order Here',
                                          onPressed: () =>
                                              _closeDrawerAndGo(AppRoutes.orderHere),
                                        ),
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, authState) {
                                            if (authState is Authenticated || authState is EmailNotVerified) {
                                              return Column(
                                                children: [
                                                  _buildMenuItem(
                                                    index: 5,
                                                    icon: Icons.person,
                                                    title: 'Profile',
                                                    onPressed: () => _closeDrawerAndGo(AppRoutes.profile),
                                                  ),
                                                  if (AdminService.isAdmin())
                                                    _buildMenuItem(
                                                      index: 6,
                                                      icon: Icons.admin_panel_settings,
                                                      title: 'Admin - Orders',
                                                      onPressed: () => _closeDrawerAndGo(AppRoutes.adminOrders),
                                                    ),
                                                ],
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                        _buildMenuItem(
                                          index: 7,
                                          icon: Icons.connect_without_contact,
                                          title: 'Contact Us',
                                          onPressed: () =>
                                              _closeDrawerAndGo(AppRoutes.contact),
                                        ),
                                      ],
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
            ],
          ),
        ),
        // Menu button - moves with drawer, stays at right edge of drawer when open
        AnimatedPositioned(
          duration: _animationController.duration ?? const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          left: isSlideOpen ? drawerWidth + 3 : 0,
          top: (he / 2) - 55,
          child: Semantics(
            label: isSlideOpen ? 'Close menu' : 'Open menu',
            button: true,
            child: InkWell(
              onTap: () {
                setState(() {
                  isSlideOpen = !isSlideOpen;
                  if (isSlideOpen) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
              child: Align(
                alignment: const Alignment(0, -0.5),
                child: ClipPath(
                  clipper: CustomMenuClipper(),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: 35,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            HomeWarmColors.drawerNavyTint.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.025),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedIcon(
                          color: ColorManager.textPrimary,
                          size: 25,
                          icon: AnimatedIcons.menu_close,
                          progress: _animationController.view,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    Path path = Path();
    // Clipping from left side now (mirrored)
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width, width, width, height / 2);
    path.quadraticBezierTo(width, height - width, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
