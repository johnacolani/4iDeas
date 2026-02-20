import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../ColorManager.dart';

class SEOOptimizationSection extends StatelessWidget {
  final double wi;
  final bool isMobile;

  const SEOOptimizationSection({
    super.key,
    required this.wi,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'step': '1',
        'title': 'Meta Tags Optimization',
        'description': 'Implement comprehensive meta tags including title, description, Open Graph, and Twitter Cards for better search engine visibility',
        'icon': Icons.code,
      },
      {
        'step': '2',
        'title': 'Structured Data',
        'description': 'Add JSON-LD structured data (Schema.org) to help search engines understand your content and enable rich snippets',
        'icon': Icons.data_object,
      },
      {
        'step': '3',
        'title': 'Sitemap & Robots.txt',
        'description': 'Generate and submit XML sitemap to search engines. Configure robots.txt for proper crawling',
        'icon': Icons.map,
      },
      {
        'step': '4',
        'title': 'Performance Optimization',
        'description': 'Optimize images, enable compression, implement lazy loading, and minimize bundle size for faster page loads',
        'icon': Icons.speed,
      },
      {
        'step': '5',
        'title': 'Mobile Optimization',
        'description': 'Ensure responsive design, fast mobile loading, and proper viewport configuration for mobile-first indexing',
        'icon': Icons.phone_android,
      },
      {
        'step': '6',
        'title': 'Content & Keywords',
        'description': 'Optimize content with relevant keywords, create quality content, and ensure proper heading hierarchy (H1-H6)',
        'icon': Icons.text_fields,
      },
      {
        'step': '7',
        'title': 'SSL & Security',
        'description': 'Implement HTTPS, ensure secure connections, and follow security best practices for better search rankings',
        'icon': Icons.lock,
      },
      {
        'step': '8',
        'title': 'Analytics & Monitoring',
        'description': 'Set up Google Analytics, Search Console, and monitor performance metrics to track and improve rankings',
        'icon': Icons.analytics,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? (wi < 400 ? wi * 0.03 : wi * 0.04) : wi * 0.1,
        vertical: 4.h,
      ),
      padding: EdgeInsets.all(isMobile ? (wi < 400 ? 12 : 16) : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.blue.withValues(alpha: 0.15),
            ColorManager.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorManager.blue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.blue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // SEO Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: ColorManager.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: ColorManager.blue,
                  size: 40,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              SelectableText(
                'SEO Optimization',
                style: GoogleFonts.albertSans(
                  fontSize: isMobile ? (wi < 400 ? 24.sp * 1.3 * 0.7 * 0.7 : 28.sp * 1.3 * 0.7 * 0.7) : wi * 0.028,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SelectableText(
            'Step-by-Step Guide to High Rankings',
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? (wi < 400 ? 16.sp * 1.3 * 0.7 * 0.7 : 18.sp * 1.3 * 0.7 * 0.7) : wi * 0.018,
              color: ColorManager.blue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // Steps List
          ...steps.map((step) {
            return Container(
              margin: EdgeInsets.only(bottom: isMobile ? (wi < 400 ? 12 : 14) : 20),
              padding: EdgeInsets.all(isMobile ? (wi < 400 ? 12 : 14) : 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Number
                  Container(
                    width: isMobile ? 40 : 50,
                    height: isMobile ? 40 : 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ColorManager.blue, ColorManager.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SelectableText(
                        step['step'],
                        style: GoogleFonts.albertSans(
                          fontSize: isMobile ? 18.sp * 1.3 * 0.7 * 0.7 : wi * 0.017,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  // Step Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              step['icon'],
                              color: ColorManager.orange,
                              size: isMobile ? 28 : wi * 0.028,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                step['title'],
                                style: GoogleFonts.albertSans(
                                  fontSize: isMobile ? 16.sp * 1.3 * 0.7 * 0.7 : wi * 0.015,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        SelectableText(
                          step['description'],
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? 13.sp * 1.3 * 0.7 * 0.7 : wi * 0.012,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
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
}

