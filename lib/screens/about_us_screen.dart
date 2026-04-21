import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    
    // Responsive font sizes
    final double titleFontSize = isMobile ? 28 : (isTablet ? 32 : 36);
    final double sectionTitleSize = isMobile ? 22 : (isTablet ? 24 : 26);
    final double bodyFontSize = isMobile ? 16 : (isTablet ? 17 : 18);
    final double subtitleFontSize = isMobile ? 14 : (isTablet ? 15 : 16);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: IconThemeData(
          color: ColorManager.backgroundDark,
        ),
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
          'About 4iDeas',
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
              child: CustomScrollView(
                slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : (isTablet ? 24.0 : 32.0),
                      vertical: isMobile ? 20.0 : 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : (isTablet ? 700 : 800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      '4iDeas',
                                      style: GoogleFonts.albertSans(
                                        color: ColorManager.accentGoldDark,
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  Text(
                                    'Founder-led product design & Flutter consultancy',
                                    style: TextStyle(
                                      color: ColorManager.primaryTeal,
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SizedBox(height: he * 0.006),
                                  Text(
                                    'Led by John A. Colani',
                                    style: TextStyle(
                                      color: ColorManager.textSecondary,
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.008),
                                  Text(
                                    'Richmond, VA',
                                    style: TextStyle(
                                      color: ColorManager.accentGoldDark.withValues(alpha: 0.8),
                                      fontSize: subtitleFontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: he * 0.03),
                                ],
                              ),
                            ),
                            
                            // Summary Section
                            _buildSection(
                              title: 'About',
                              content: '4iDeas is a founder-led product consultancy focused on turning business ideas into shipped software. We combine product strategy, UX/UI, and Flutter engineering so teams can move from concept to production with less handoff friction and better decision quality.\n\nJohn A. Colani leads every engagement directly. With 6+ years across enterprise and startup-style products, the work covers multi-role platforms, workflow-heavy apps, design systems, and AI-assisted product features with practical governance.',
                              fontSize: bodyFontSize,
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Core Skills Section
                            _buildSection(
                              title: 'Core Skills',
                              content: 'UX Design (flows, wireframes, journeys, IA, prototyping) • UI Design (visual, layout systems, high-fidelity UI) • Design Systems (components, tokens, documentation) • Research Integration • Usability Testing • Accessibility (WCAG 2.2) • Responsive Design • Figma • Miro • FigJam • Adobe Suite • Engineering Collaboration • Storytelling & Communication',
                              fontSize: bodyFontSize,
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Experience Section
                            _buildExperienceSection(
                              title: 'Professional Experience',
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Education Section
                            _buildSection(
                              title: 'Education',
                              content: 'M.A. – Product Design, University of Tehran\nB.A. – Industrial Design, University of Tehran',
                              fontSize: bodyFontSize,
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                            ),
                            
                            SizedBox(height: he * 0.04),
                            
                            // Contact Links Section
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 20 : 24),
                                decoration: ColorManager.loginAuthCardDecoration(borderRadius: 16),
                                child: Column(
                                  children: [
                                    SelectableText(
                                      'Let\'s Connect',
                                      style: GoogleFonts.albertSans(
                                        color: ColorManager.accentGoldDark,
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    _buildContactLink(
                                      icon: Icons.email,
                                      label: 'Email',
                                      value: 'info@4ideasapp.com',
                                      onTap: () => _launchEmail('info@4ideasapp.com'),
                                      isMobile: isMobile,
                                      bodyFontSize: bodyFontSize,
                                    ),
                                    SizedBox(height: 12),
                                    _buildContactLink(
                                      icon: Icons.phone,
                                      label: 'Phone',
                                      value: '804-774-9008',
                                      onTap: () => _launchPhone('8047749008'),
                                      isMobile: isMobile,
                                      bodyFontSize: bodyFontSize,
                                    ),
                                    SizedBox(height: 12),
                                    _buildContactLink(
                                      icon: Icons.work,
                                      label: 'LinkedIn',
                                      value: 'linkedin.com/in/john-colani-43344a70',
                                      onTap: () => _launchURL('https://www.linkedin.com/in/john-colani-43344a70/'),
                                      isMobile: isMobile,
                                      bodyFontSize: bodyFontSize,
                                    ),
                                    SizedBox(height: 12),
                                    _buildContactLink(
                                      icon: Icons.public,
                                      label: 'Portfolio',
                                      value: 'View Portfolio',
                                      onTap: () => _launchURL('https://4ideasapp.com/portfolio'),
                                      isMobile: isMobile,
                                      bodyFontSize: bodyFontSize,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: he * 0.04),
                          ],
                        ),
                      ),
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

  Widget _buildSection({
    required String title,
    required String content,
    required double fontSize,
    required double he,
    required bool isMobile,
    required double sectionTitleSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            title,
            style: GoogleFonts.albertSans(
              color: ColorManager.accentGoldDark,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: he * 0.015),
          SelectableText(
            content,
            style: TextStyle(
              color: ColorManager.textSecondary,
              fontSize: fontSize,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection({
    required String title,
    required double he,
    required bool isMobile,
    required double sectionTitleSize,
    required double bodyFontSize,
  }) {
    final experiences = [
      {
        'company': 'Absolute Stone Design',
        'role': 'Senior Product Designer',
        'period': '2024–Present',
        'highlights': [
          'Led end-to-end design for a multi-role enterprise platform across mobile and web.',
          'Built a full design system (tokens, components, patterns) enhancing consistency and developer efficiency.',
          'Created IA, flows, wireframes, and prototypes that simplified complex workflows.',
          'Partnered with research for iterative improvements and ensured WCAG 2.2 compliance.',
          'Designed and shipped "Amy," the company\'s AI assistant with controlled knowledge governance.',
        ],
      },
      {
        'company': 'Woven by Toyota',
        'role': 'Product Designer, Connected Systems',
        'period': '2023–2024',
        'highlights': [
          'Designed real-time connected car interfaces with safety and clarity as core principles.',
          'Contributed cross-platform components to internal design systems.',
          'Improved multi-step flows and hierarchical structures to enhance usability.',
          'Partnered with engineers to validate interactions, constraints, and system logic.',
        ],
      },
      {
        'company': 'Phillips Industries',
        'role': 'Product Designer, IoT Systems',
        'period': '2022–2023',
        'highlights': [
          'Designed telematics dashboards, configurations, and sensor-based workflows.',
          'Improved data-heavy interfaces through better IA and scannability.',
          'Built prototypes reflecting real interaction states and system logic.',
          'Influenced component patterns and design documentation for engineering teams.',
        ],
      },
      {
        'company': 'Cognizant',
        'role': 'Product Designer',
        'period': '2021–2022',
        'highlights': [
          'Delivered UX for enterprise-scale applications including IA, flows, prototypes, and UI patterns.',
          'Created reusable design components to support multiple teams and products.',
          'Collaborated with PMs, engineers, and researchers in agile environments.',
          'Conducted usability testing and integrated insights into iterative improvements.',
        ],
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.albertSans(
              color: ColorManager.accentGoldDark,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: he * 0.02),
          ...experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < experiences.length - 1 ? 24 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              exp['company'] as String,
                              style: GoogleFonts.albertSans(
                                color: ColorManager.accentGoldDark,
                                fontSize: bodyFontSize + 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            SelectableText(
                              exp['role'] as String,
                              style: TextStyle(
                                color: ColorManager.primaryTeal,
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SelectableText(
                        exp['period'] as String,
                        style: TextStyle(
                          color: ColorManager.accentGoldDark.withValues(alpha: 0.7),
                          fontSize: bodyFontSize - 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...(exp['highlights'] as List<String>).map((highlight) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                            Padding(
                              padding: EdgeInsets.only(top: 6, right: 8),
                              child: Icon(
                                Icons.arrow_right,
                                color: ColorManager.primaryTeal,
                                size: 18,
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                highlight,
                                style: TextStyle(
                                  color: ColorManager.textSecondary,
                                  fontSize: bodyFontSize - 1,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (index < experiences.length - 1)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Divider(
                        color: ColorManager.containerBorder,
                        thickness: 1,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactLink({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
    required double bodyFontSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorManager.containerSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorManager.containerBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ColorManager.primaryTeal,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    label,
                    style: TextStyle(
                      color: ColorManager.textMuted,
                      fontSize: bodyFontSize - 2,
                    ),
                  ),
                  SizedBox(height: 2),
                  SelectableText(
                    value,
                    style: TextStyle(
                      color: ColorManager.textPrimary,
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorManager.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
