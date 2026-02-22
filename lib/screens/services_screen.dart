import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: SelectableText(
          'Services',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
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
                                  SelectableText(
                                    'Our Services',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Professional Product Design Services',
                                    style: TextStyle(
                                      color: ColorManager.orange,
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.03),
                                ],
                              ),
                            ),
                            
                            // UX Design Service
                            _buildServiceCard(
                              icon: Icons.design_services,
                              title: 'UX Design',
                              subtitle: 'User Experience Design',
                              description: 'Comprehensive UX design services including user flows, wireframes, user journeys, information architecture, and interactive prototyping. Specialized in simplifying complex workflows and creating intuitive digital experiences.',
                              details: [
                                'User flows & journey mapping',
                                'Wireframes & low-fidelity prototypes',
                                'Information architecture (IA)',
                                'Usability testing & research integration',
                                'Interaction design patterns',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // UI Design Service
                            _buildServiceCard(
                              icon: Icons.palette,
                              title: 'UI Design',
                              subtitle: 'Visual & Interface Design',
                              description: 'High-fidelity UI design with attention to visual hierarchy, layout systems, and pixel-perfect implementation. Creating beautiful, accessible, and responsive interfaces.',
                              details: [
                                'Visual design & layout systems',
                                'High-fidelity UI components',
                                'Responsive design (mobile, tablet, web)',
                                'Accessibility (WCAG 2.2 compliance)',
                                'Design specifications & handoff',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Design Systems Service
                            _buildServiceCard(
                              icon: Icons.extension,
                              title: 'Design Systems',
                              subtitle: 'Component Libraries & Documentation',
                              description: 'Build scalable design systems with reusable components, design tokens, and comprehensive documentation. Enhancing consistency and developer efficiency across teams and products.',
                              details: [
                                'Component libraries & patterns',
                                'Design tokens (colors, typography, spacing)',
                                'Design system documentation',
                                'Component maintenance & governance',
                                'Cross-platform design systems',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Research & Testing Service
                            _buildServiceCard(
                              icon: Icons.psychology,
                              title: 'Research & Usability Testing',
                              subtitle: 'User-Centered Design Process',
                              description: 'Data-driven design decisions through user research, usability testing, and iterative improvements. Integrating insights into design workflows.',
                              details: [
                                'User research & interviews',
                                'Usability testing & analysis',
                                'Research integration',
                                'Iterative design improvements',
                                'User-centered design methodologies',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Product Design Service
                            _buildServiceCard(
                              icon: Icons.phone_android,
                              title: 'Product Design',
                              subtitle: 'End-to-End Product Design',
                              description: 'Full product design services for web, mobile, enterprise platforms, dashboards, CMS environments, workflow tools, and AI-assisted product experiences.',
                              details: [
                                'Web & mobile app design',
                                'Enterprise platform design',
                                'Dashboard & data visualization',
                                'CMS & workflow tools',
                                'AI-powered product experiences',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.025),
                            
                            // Collaboration Service
                            _buildServiceCard(
                              icon: Icons.handshake,
                              title: 'Engineering Collaboration',
                              subtitle: 'Design-to-Development Partnership',
                              description: 'Close collaboration with engineering teams to ensure accurate implementation, maintain design consistency, and bring ideas to life with precision.',
                              details: [
                                'Design-to-development handoff',
                                'Engineering collaboration & validation',
                                'Design consistency enforcement',
                                'Storytelling & communication',
                                'Agile design processes',
                              ],
                              he: he,
                              isMobile: isMobile,
                              sectionTitleSize: sectionTitleSize,
                              bodyFontSize: bodyFontSize,
                            ),
                            
                            SizedBox(height: he * 0.04),
                            
                            // Call to Action
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 20 : 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorManager.blue.withValues(alpha: 0.2),
                                      ColorManager.orange.withValues(alpha: 0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SelectableText(
                                      'Ready to start your project?',
                                      style: GoogleFonts.albertSans(
                                        color: Colors.white,
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SelectableText(
                                      'Let\'s discuss how we can bring your ideas to life',
                                      style: TextStyle(
                                        color: ColorManager.orange,
                                        fontSize: bodyFontSize,
                                      ),
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

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required List<String> details,
    required double he,
    required bool isMobile,
    required double sectionTitleSize,
    required double bodyFontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: ColorManager.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ColorManager.orange,
                  size: isMobile ? 28 : 32,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      title,
                      style: GoogleFonts.albertSans(
                        color: ColorManager.orange,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: bodyFontSize - 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: he * 0.015),
          SelectableText(
            description,
            style: TextStyle(
              color: Colors.white,
              fontSize: bodyFontSize,
              height: 1.6,
            ),
          ),
          SizedBox(height: he * 0.015),
          ...details.map((detail) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: ColorManager.blue,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        detail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: bodyFontSize - 1,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
