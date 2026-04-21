import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_router.dart';
import '../config/lead_capture_config.dart';
import '../core/ColorManager.dart';
import '../core/home_warm_colors.dart';
import '../core/widgets/frosted_app_bar.dart';
import '../core/widgets/project_inquiry_form.dart';
import '../helper/app_background.dart';
import '../helper/contact_us_content.dart';

/// Full-page contact and project inquiry. URL: [AppRoutes.contact].
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _openCalendly() async {
    final url = LeadCaptureConfig.calendlyIntroUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;
    final isTablet = wi >= 600 && wi < 1024;
    final hPad = isMobile ? 16.0 : (isTablet ? 28.0 : 36.0);
    final bodySize = isMobile ? 15.0 : 16.0;
    final titleSize = isMobile ? 26.0 : 30.0;
    final showCalendly = LeadCaptureConfig.calendlyIntroUrl.trim().isNotEmpty;

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
          'Contact',
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
                      maxWidth: isMobile ? double.infinity : 880,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Start a project conversation',
                            style: GoogleFonts.albertSans(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: HomeWarmColors.headlinePrimary,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: isMobile ? 10 : 12),
                          Text(
                            'If you are a startup or business exploring Flutter, product design, or Firebase, you are in the right place. '
                            'Share a few details below and I will respond with thoughtful next steps—whether that is a rough estimate, a short call, or an honest “not a fit.”',
                            style: GoogleFonts.albertSans(
                              fontSize: bodySize,
                              fontWeight: FontWeight.w500,
                              color: HomeWarmColors.bodyEmphasis,
                              height: 1.55,
                            ),
                          ),
                          SizedBox(height: isMobile ? 8 : 10),
                          Text(
                            'Typical reply time: one to two business days.',
                            style: GoogleFonts.albertSans(
                              fontSize: bodySize - 0.5,
                              fontWeight: FontWeight.w600,
                              color: HomeWarmColors.eyebrowMuted,
                            ),
                          ),
                          if (showCalendly) ...[
                            SizedBox(height: isMobile ? 18 : 22),
                            OutlinedButton.icon(
                              onPressed: _openCalendly,
                              icon: Icon(Icons.calendar_month_rounded, color: HomeWarmColors.sectionAccent),
                              label: Text(
                                'Schedule a short intro call',
                                style: GoogleFonts.albertSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: bodySize,
                                  color: HomeWarmColors.sectionAccent,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: isMobile ? 14 : 16,
                                ),
                                side: const BorderSide(color: HomeWarmColors.sectionAccent, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Optional—use this if you would rather pick a time than wait on email.',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                color: ColorManager.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                          SizedBox(height: isMobile ? 24 : 28),
                          const ProjectInquiryForm(),
                          SizedBox(height: isMobile ? 36 : 44),
                          Row(
                            children: [
                              Expanded(child: Divider(color: HomeWarmColors.dividerLine)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or reach me directly',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: HomeWarmColors.bodyEmphasis.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: HomeWarmColors.dividerLine)),
                            ],
                          ),
                          SizedBox(height: isMobile ? 20 : 24),
                          const ContactUsContent(
                            embeddedInDialog: false,
                            paddingOverride: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
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
