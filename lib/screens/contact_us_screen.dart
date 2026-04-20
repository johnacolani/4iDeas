import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';
import '../core/ColorManager.dart';
import '../core/widgets/frosted_app_bar.dart';
import '../helper/app_background.dart';
import '../helper/contact_us_content.dart';

/// Full-page contact (replaces modal-only flow). URL: [AppRoutes.contact].
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.backgroundDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          'Contact Us',
          style: GoogleFonts.albertSans(
            color: ColorManager.backgroundDark,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 560,
                    ),
                    child: const ContactUsContent(embeddedInDialog: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
