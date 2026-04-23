import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/data/services_data.dart';

/// Resolves [ServiceItem.iconName] to Material [IconData] for the public site and admin hints.
IconData serviceIconDataFromKey(String name) {
  switch (name) {
    case 'rocket_launch':
      return Icons.rocket_launch_rounded;
    case 'integration_instructions':
      return Icons.integration_instructions_rounded;
    case 'auto_awesome':
      return Icons.auto_awesome_rounded;
    case 'autorenew':
      return Icons.autorenew_rounded;
    case 'design_services':
      return Icons.design_services_rounded;
    case 'palette':
      return Icons.palette_rounded;
    case 'extension':
      return Icons.extension_rounded;
    case 'psychology':
      return Icons.psychology_rounded;
    case 'phone_android':
      return Icons.phone_android_rounded;
    case 'handshake':
      return Icons.handshake_rounded;
    default:
      return Icons.widgets_rounded;
  }
}

/// Premium service card: outcome line, scope, included list, ideal client, CTA.
class ServiceOfferingCard extends StatelessWidget {
  const ServiceOfferingCard({
    super.key,
    required this.item,
    required this.isMobile,
    required this.sectionTitleSize,
    required this.bodyFontSize,
    required this.onCta,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  final ServiceItem item;
  final bool isMobile;
  final double sectionTitleSize;
  final double bodyFontSize;
  final VoidCallback onCta;

  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const LinearGradient _goldGradient = LinearGradient(
    colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
  );

  @override
  Widget build(BuildContext context) {
    final icon = serviceIconDataFromKey(item.iconName);

    Widget card = Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A).withValues(alpha: 0.95),
              const Color(0xFF111827).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: _goldGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 18 : 22, isMobile ? 18 : 22, isMobile ? 18 : 22, isMobile ? 18 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 11 : 13),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.42),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.primaryGold,
                          size: isMobile ? 26 : 30,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  _goldGradient.createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                item.title,
                                style: GoogleFonts.albertSans(
                                  color: Colors.white,
                                  fontSize: sectionTitleSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            SelectableText(
                              item.subtitle,
                              style: GoogleFonts.albertSans(
                                color: const Color(0xFFD1D5DB),
                                fontSize: bodyFontSize - 1,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (item.valueProposition.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 14 : 16),
                    SelectableText(
                      item.valueProposition,
                      style: GoogleFonts.albertSans(
                        color: AppColors.primaryGold,
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                  SizedBox(height: isMobile ? 12 : 14),
                  SelectableText(
                    item.description,
                    style: GoogleFonts.albertSans(
                      color: const Color(0xFFD1D5DB),
                      fontSize: bodyFontSize,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 18),
                  Text(
                    'What’s included',
                    style: GoogleFonts.albertSans(
                      color: Colors.white,
                      fontSize: bodyFontSize - 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 10),
                  ...item.details.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, right: 10),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryGold.withValues(alpha: 0.85),
                              size: 18,
                            ),
                          ),
                          Expanded(
                            child: SelectableText(
                              detail,
                              style: GoogleFonts.albertSans(
                                color: const Color(0xFFD1D5DB),
                                fontSize: bodyFontSize - 1,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.idealClient.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 12 : 14),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 14,
                        vertical: isMobile ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best for',
                            style: GoogleFonts.albertSans(
                              color: AppColors.primaryGold,
                              fontSize: bodyFontSize - 2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          SelectableText(
                            item.idealClient,
                            style: GoogleFonts.albertSans(
                              color: const Color(0xFFD1D5DB),
                              fontSize: bodyFontSize - 1,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: isMobile ? 18 : 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: const Color(0xFF0B0F19),
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onCta,
                      child: Text(
                        item.ctaLabel,
                        style: GoogleFonts.albertSans(
                          fontSize: bodyFontSize - 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showAdminActions && (onEdit != null || onDelete != null))
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          tooltip: 'Edit',
                          icon: Icon(Icons.edit_rounded, size: 22, color: AppColors.primaryGold),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(Icons.delete_outline_rounded, size: 22, color: Colors.red.shade700),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return card;
  }
}
