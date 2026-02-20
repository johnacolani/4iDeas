import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/helper/menu_item.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/features/auth/presentation/screens/login_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/profile_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/signup_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/screens/about_us_screen.dart';
import 'package:four_ideas/screens/order_here_screen.dart';
import 'package:four_ideas/screens/portfolio_screen.dart';
import 'package:four_ideas/screens/services_screen.dart';
import 'package:sizer/sizer.dart';

import 'alert_dialog_data.dart';


class SlidingMenu extends StatefulWidget {
  const SlidingMenu({super.key});

  @override
  State<SlidingMenu> createState() => _SlidingMenuState();
}

class _SlidingMenuState extends State<SlidingMenu>
    with SingleTickerProviderStateMixin {
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
            final isFullyOpen = _animationController.value == 1.0;
            return Positioned(
              left: drawerWidth,
              top: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !isFullyOpen,
                child: GestureDetector(
                  onTap: () {
                    if (isFullyOpen) {
                      setState(() {
                        isSlideOpen = false;
                        _animationController.reverse();
                      });
                    }
                  },
                  child: Container(
                    color: isFullyOpen 
                        ? Colors.black.withValues(alpha: 0.3)
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2D3748),
                      const Color(0xFF1A202C),
                    ],
                  ),
                ),
                width: isMobile ? 2 : 3,
                height: he,
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 20 : 24),
                  bottomLeft: Radius.circular(isMobile ? 20 : 24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: he,
                    width: drawerWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4B556E).withValues(alpha: 0.2),
                          const Color(0xFF2D3748).withValues(alpha: 0.25),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        right: BorderSide(
                          color: Colors.white,
                          width: 2.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(5, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 14.0 : 16.0),
                      child: Column(
                        children: [
                      SizedBox(
                        height: isMobile ? 2.h : 3.h,
                      ),
                      // Header Section with better styling
                      Container(
                        padding: EdgeInsets.all(isMobile ? 14 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
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
                                  color: ColorManager.orange.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: isMobile ? 35 : 38,
                                backgroundImage:
                                    const AssetImage('assets/images/logo.png'),
                              ),
                            ),
                            SizedBox(height: isMobile ? 12 : 14),
                            SelectableText(
                              '4iDeas',
                              style: TextStyle(
                                fontSize: isMobile ? 22 : (isTablet ? 20 : 18),
                                fontWeight: FontWeight.bold,
                                color: ColorManager.orange,
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
                                    ColorManager.blue.withValues(alpha: 0.15),
                                    ColorManager.orange.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SelectableText(
                                    "Let's Talk! 🇺🇸",
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : (isTablet ? 13 : 12),
                                      color: ColorManager.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    "804-774-9008",
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : (isTablet ? 17 : 16),
                                      color: ColorManager.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
                            MenuItem(
                              icon: Icons.design_services,
                              title: 'Services',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ServicesScreen()));
                              },
                            ),
                            MenuItem(
                              icon: Icons.people,
                              title: 'About Us',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AboutUsScreen()));
                              },
                            ),
                            MenuItem(
                              icon: Icons.note,
                              title: 'Portfolio',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>const PortfolioScreen()));
                              },
                            ),
                            MenuItem(
                              icon: Icons.contrast,
                              title: 'Order Here',
                              onPressed: () {
                                final authState = context.read<AuthBloc>().state;
                                if (authState is Authenticated) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const OrderHereScreen()));
                                } else {
                                  _showSignUpRequiredDialog(context, isMobile);
                                }
                              },
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                if (authState is Authenticated || authState is EmailNotVerified) {
                                  return Column(
                                    children: [
                                      MenuItem(
                                        icon: Icons.person,
                                        title: 'Profile',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ProfileScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      // Admin menu item (only visible to admins)
                                      if (AdminService.isAdmin())
                                        MenuItem(
                                          icon: Icons.admin_panel_settings,
                                          title: 'Admin - Orders',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const AdminOrdersScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            MenuItem(
                              icon: Icons.connect_without_contact,
                              title: 'Contact Us',
                              onPressed: () {
                                // Show a dialog when the button is pressed
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialogData(wi: wi , he: he,);
                                  },
                                );
                              },
                            ),
                              ],
                            ),
                          ),
                        ),
                      ),
                        ],
                      ),
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
              child: Stack(
                children: [
                  ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 35,
                      height: 110,
                      color: const Color(0xFF4B556E),
                      alignment: Alignment.center,
                      child: AnimatedIcon(
                        color: ColorManager.white,
                        size: 25,
                        icon: AnimatedIcons.menu_close,
                        progress: _animationController.view,
                      ),
                    ),
                  ),
                  // White border on front (right), top, and bottom
                  CustomPaint(
                    size: const Size(35, 110),
                    painter: _MenuBorderPainter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSignUpRequiredDialog(BuildContext context, bool isMobile) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4B556E).withValues(alpha: 0.95),
                  const Color(0xFF2D3748).withValues(alpha: 0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: ColorManager.orange,
                ),
                SizedBox(height: isMobile ? 16 : 20),
                SelectableText(
                  'Sign Up Required',
                  style: GoogleFonts.albertSans(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                SelectableText(
                  'You need to sign up first to place an order. Please create an account to continue.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isMobile ? 15 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 24 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 24,
                          vertical: isMobile ? 12 : 14,
                        ),
                        backgroundColor: ColorManager.blue.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: ColorManager.blue,
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? 120 : 140,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _MenuBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final path = Path();
    
    // Start from top-left curve (where it curves to the right)
    path.moveTo(10, 16);
    
    // Top border - along the top curve to right edge
    path.quadraticBezierTo(width, width, width, height / 2);
    
    // Right border (front) - continue down the right side
    path.quadraticBezierTo(width, height - width, 10, height - 16);
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw top border line (horizontal at the top)
    final topPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(0, 0),
      Offset(10, 16),
      topPaint,
    );
    
    // Draw bottom border line (horizontal at the bottom)
    canvas.drawLine(
      Offset(0, height),
      Offset(10, height - 16),
      topPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}