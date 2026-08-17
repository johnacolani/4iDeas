import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';

/// Shown when a non-admin reaches an admin screen.
///
/// This is a courtesy, not a security boundary: the same request is
/// independently refused by Firestore rules, Storage rules and `requireAdmin`
/// in Cloud Functions, all of which read the verified ID token.
class AdminAccessDenied extends StatelessWidget {
  const AdminAccessDenied({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        // Reaching this screen usually means following an admin link while
        // signed in as somebody else, so the way out matters more here than
        // anywhere: without it a cold deep link leaves no arrow at all.
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 46, color: ColorManager.accentGold),
                  const SizedBox(height: 20),
                  Text(
                    'Administrator access required',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      'Sign in with an administrator account to manage 4iCAD.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('Back to home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorManager.accentGold,
                      foregroundColor: const Color(0xFF1A1305),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
