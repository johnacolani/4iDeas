import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../core/ColorManager.dart';
import '../app_router.dart';

class AlertDialogData extends StatelessWidget {
  const AlertDialogData({
    super.key,
    required this.wi,
    required this.he,
  });

  final double wi;
  final double he;

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4B556E).withValues(alpha: 0.95),
              const Color(0xFF2D3748).withValues(alpha: 0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section - styled like drawer header
                Container(
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorManager.orange.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: isMobile ? 35 : 40,
                          backgroundImage:
                              const AssetImage('assets/images/logo.png'),
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'John A. Colani',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Senior Product Designer',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                // Contact Information Section
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: '804-774-9008',
                        onTap: () => _launchPhone('8047749008'),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        thickness: 1,
                      ),
                      SizedBox(height: 12),
                      _buildContactItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: 'johnacolani@gmail.com',
                        onTap: () => _launchEmail('johnacolani@gmail.com'),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        thickness: 1,
                      ),
                      SizedBox(height: 12),
                      _buildContactItem(
                        icon: Icons.work,
                        label: 'LinkedIn',
                        value: 'View Profile',
                        onTap: () => _launchURL(
                            'https://www.linkedin.com/in/john-colani-43344a70/'),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        thickness: 1,
                      ),
                      SizedBox(height: 12),
                      _buildContactItem(
                        icon: Icons.public,
                        label: 'Portfolio',
                        value: 'View Portfolio',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(AppRoutes.portfolio);
                        },
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.orange.withValues(alpha: 0.2),
                      foregroundColor: ColorManager.white,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: ColorManager.orange.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: ColorManager.orange,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
