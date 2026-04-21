import 'package:flutter/material.dart';

import '../core/ColorManager.dart';

class MenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? cardColor;
  final Gradient? cardGradient;
  final Color? accentColor;


  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.cardColor,
    this.cardGradient,
    this.accentColor,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
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
    final Color accent = widget.accentColor ?? ColorManager.primaryTeal;
    final Color iconColor = ColorManager.textPrimary;
    final Color titleColor = ColorManager.textPrimary;
    
    return AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        margin: EdgeInsets.symmetric(vertical: isMobile ? 4.0 : 3.0),
        decoration: BoxDecoration(
          color: widget.cardGradient == null
              ? (widget.cardColor ?? Colors.transparent)
              : null,
          gradient: widget.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: horizontalPadding,
                top: isMobile ? 12.0 : 10.0,
                bottom: isMobile ? 12.0 : 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  Icon(
                    widget.icon,
                    size: iconSize,
                    color: iconColor,
                  ),
                  SizedBox(width: isMobile ? 14 : (isTablet ? 12 : 10)),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: titleColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
