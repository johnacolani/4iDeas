import 'package:flutter/material.dart';

import '../core/ColorManager.dart';

class MenuItem extends StatefulWidget {
  final String title;
  final  IconData icon;
  final VoidCallback onPressed;


  const MenuItem({super.key, required this.icon, required this.title, required this.onPressed});

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    
    // Responsive sizing - more responsive font sizes based on screen width
    final double iconSize = isMobile ? 22 : (isTablet ? 20 : 18);
    final double fontSize = isMobile ? 16 : (isTablet ? 15 : 14);
    final double horizontalPadding = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: isMobile ? 4.0 : 3.0),
        decoration: BoxDecoration(
          gradient: _isHovered
              ? LinearGradient(
                  colors: [
                    ColorManager.blue.withValues(alpha: 0.2),
                    ColorManager.orange.withValues(alpha: 0.15),
                  ],
                )
              : null,
          color: _isHovered ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? ColorManager.orange.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: ColorManager.orange.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.only(
                left: 0,
                right: horizontalPadding,
                top: isMobile ? 12.0 : 10.0,
                bottom: isMobile ? 12.0 : 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 7 : 6),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? ColorManager.orange.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      size: iconSize,
                      color: _isHovered
                          ? ColorManager.orange
                          : ColorManager.white,
                    ),
                  ),
                  SizedBox(width: isMobile ? 14 : (isTablet ? 12 : 10)),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: ColorManager.white,
                        fontWeight: _isHovered
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (_isHovered)
                    Padding(
                      padding: EdgeInsets.only(left: isMobile ? 8 : 6),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: isMobile ? 16 : 14,
                        color: ColorManager.orange,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
