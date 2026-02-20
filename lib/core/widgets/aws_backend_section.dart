import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AWSBackendSection extends StatelessWidget {
  final double wi;
  final bool isMobile;

  const AWSBackendSection({
    super.key,
    required this.wi,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> services = [
      {
        'name': 'EC2',
        'iconPath': 'assets/icons/ec2.png',
        'description': 'Scalable virtual servers in the cloud with flexible compute capacity'
      },
      {
        'name': 'Lambda',
        'iconPath': 'assets/icons/lambda.png',
        'description': 'Run code without managing servers - pay only for compute time used'
      },
      {
        'name': 'S3 Storage',
        'iconPath': 'assets/icons/s3.png',
        'description': 'Object storage service with industry-leading scalability and durability'
      },
      {
        'name': 'RDS Database',
        'iconPath': 'assets/icons/rds.png',
        'description': 'Managed relational database service (MySQL, PostgreSQL, etc.)'
      },
      {
        'name': 'API Gateway',
        'iconPath': 'assets/icons/api-gateway.png',
        'description': 'Create, publish, and manage REST and WebSocket APIs at scale'
      },
      {
        'name': 'DynamoDB',
        'iconPath': 'assets/icons/dynamodb.png',
        'description': 'Fast NoSQL database with single-digit millisecond performance'
      },
      {
        'name': 'CloudFront',
        'iconPath': 'assets/icons/cloudfront.png',
        'description': 'Global content delivery network for fast, secure content delivery'
      },
      {
        'name': 'SNS/SQS',
        'iconPath': 'assets/icons/sns.png',
        'description': 'Message queuing and notification services for decoupled applications'
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
            Colors.teal.withValues(alpha: 0.15),
            Colors.teal.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.teal.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AWS Logo/Header
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
                    'assets/images/aws.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.cloud,
                        color: Color(0xFFFF9900),
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              SelectableText(
                'AWS',
                style: GoogleFonts.albertSans(
                  fontSize: isMobile ? (wi < 400 ? 24.sp * 1.3 : 28.sp * 1.3) : wi * 0.028,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SelectableText(
            'Enterprise Cloud Infrastructure',
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? (wi < 400 ? 16.sp * 1.3 * 0.7 * 0.7 * 0.8 : 18.sp * 1.3 * 0.7 * 0.7 * 0.8) : wi * 0.018,
              color: Colors.teal,
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
                color: Colors.teal.withValues(alpha: 0.2),
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
                                fontSize: isMobile ? (wi < 400 ? 14.sp * 1.3 * 0.7 * 0.7 : 16.sp * 1.3 * 0.7 * 0.7) : wi * 0.018,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            SelectableText(
                              service['description'] ?? '',
                              style: GoogleFonts.albertSans(
                                fontSize: isMobile ? (wi < 400 ? 12.sp * 1.3 * 0.7 : 14.sp * 1.3 * 0.7) : (wi < 1024 ? 11 : 13),
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
