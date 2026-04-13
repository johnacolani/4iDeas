import 'package:flutter/material.dart';

import '../core/ColorManager.dart';
import 'contact_us_content.dart';

/// Modal contact sheet (same content as [ContactUsScreen]). Prefer routing to [AppRoutes.contact] from the drawer.
class AlertDialogData extends StatelessWidget {
  const AlertDialogData({
    super.key,
    required this.wi,
    required this.he,
  });

  final double wi;
  final double he;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? wi * 0.9 : (isTablet ? 400 : 450),
          maxHeight: he * 0.85,
        ),
        decoration: ColorManager.loginAuthCardDecoration(borderRadius: 24),
        child: SingleChildScrollView(
          child: const ContactUsContent(embeddedInDialog: true),
        ),
      ),
    );
  }
}
