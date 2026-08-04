import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';

/// Small legal/footer link row shown under the brand wordmark at the end of the
/// home scroll (e.g. Privacy Policy). Kept minimal to match the quiet footer.
class HomeFooterLinks extends StatelessWidget {
  const HomeFooterLinks({super.key, this.bottomPadding = 24});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Center(
        child: TextButton(
          onPressed: () => context.go(AppRoutes.privacyPolicies),
          child: Text(
            'Privacy Policy',
            style: GoogleFonts.roboto(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
