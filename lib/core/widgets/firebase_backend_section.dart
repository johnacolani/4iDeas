import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../ColorManager.dart';

class FirebaseBackendSection extends StatelessWidget {
  final double wi;
  final bool isMobile;

  const FirebaseBackendSection({
    super.key,
    required this.wi,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> services = [
      {
        'name': 'Firestore',
        'iconPath': 'assets/icons/firestore.png',
        'description': 'NoSQL database for real-time data synchronization and offline support'
      },
      {
        'name': 'Authentication',
        'iconPath': 'assets/icons/auth.png',
        'description': 'Secure user authentication with multiple providers (Email, Google, Facebook, etc.)'
      },
      {
        'name': 'Cloud Functions',
        'iconPath': 'assets/icons/function.png',
        'description': 'Serverless backend code that runs in response to events and HTTPS requests'
      },
      {
        'name': 'Cloud Storage',
        'iconPath': 'assets/icons/storage.png',
        'description': 'Scalable file storage for user-generated content like images, videos, and documents'
      },
      {
        'name': 'Analytics',
        'iconPath': 'assets/icons/analytics.jpg',
        'description': 'Comprehensive app analytics and user behavior tracking'
      },
      {
        'name': 'Cloud Messaging',
        'iconPath': 'assets/icons/messaging.png',
        'description': 'Push notifications and messaging across iOS, Android, and web platforms'
      },
      {
        'name': 'Hosting',
        'iconPath': 'assets/icons/hosting.png',
        'description': 'Fast and secure web hosting with global CDN and SSL certificates'
      },
      {
        'name': 'Remote Config',
        'iconPath': 'assets/icons/config.png',
        'description': 'Change app behavior and appearance without publishing app updates'
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? wi * 0.05 : wi * 0.1,
        vertical: 4.h,
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF57C00).withValues(alpha: 0.15),
            const Color(0xFFFBC02D).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF57C00).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Firebase Logo/Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/firebase.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              SelectableText(
                'Firebase',
                style: GoogleFonts.albertSans(
                  fontSize: isMobile ? (wi < 400 ? 24 : 28) : wi * 0.028,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SelectableText(
            'Complete Backend Solutions',
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? (wi < 400 ? 14 : 16) : wi * 0.018,
              color: ColorManager.orange,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 20 : 28),
          // Services List
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF57C00).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: index < services.length - 1 ? (isMobile ? 8 : 12) : 0,
                  ),
                  padding: EdgeInsets.all(isMobile ? (wi < 400 ? 14 : 16) : 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isMobile ? 50 : wi * 0.05,
                        height: isMobile ? 50 : wi * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        child: Image.asset(
                          service['iconPath']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: isMobile ? 32 : wi * 0.032,
                              color: Colors.grey.withValues(alpha: 0.5),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                              service['name']!,
                              style: GoogleFonts.albertSans(
                                fontSize: isMobile ? (wi < 400 ? 14 : 16) : wi * 0.018,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            SelectableText(
                              service['description'] ?? '',
                              style: GoogleFonts.albertSans(
                                fontSize: isMobile ? (wi < 400 ? 12 : 14) : (wi < 1024 ? 11 : 13),
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
