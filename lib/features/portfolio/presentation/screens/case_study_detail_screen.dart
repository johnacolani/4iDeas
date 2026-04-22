import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';

/// Corner radius (in logical pixels) used for all case study images in this screen.
const double kCaseStudyImageCornerRadius = 30;
const Color _textPrimary = Colors.white;
const Color _textSecondary = Color(0xFFD1D5DB);
const Color _textMuted = Color(0xFF9CA3AF);
const Color _glassBase = Color(0xFF0F172A);
const Color _glassBaseAlt = Color(0xFF111827);
const LinearGradient _goldGradient = LinearGradient(
  colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
);

/// Adaptive Platform screenshots (landscape). Matches asset aspect so layout isn’t mistaken for phone portrait.
const double kAdaptivePlatformImageWidth = 2720;
const double kAdaptivePlatformImageHeight = 1504;
double get kAdaptivePlatformAspectRatio =>
    kAdaptivePlatformImageWidth / kAdaptivePlatformImageHeight;

/// Onboarding flow order: English (1st), Persian (2nd), Turkish (3rd), then rest by trailing number.
const List<String> _onboardingFlowFirstPaths = [
  'assets/images/on_boarding_image/on_boarding_en_1.png', // 1st: English
  'assets/images/on_boarding_image/on_boarding_fa_2.png', // 2nd: Persian
  'assets/images/on_boarding_image/on_boarding_tr_3.png', // 3rd: Turkish
];

/// Order images: first the three onboarding flows (EN, FA, TR), then rest by numbers at end of filename.
List<CaseStudyImage> _sortImagesByTrailingNumber(List<CaseStudyImage> images) {
  double orderFromPath(String path) {
    final name = path.split('/').last.replaceAll(
        RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '');
    final parts = name.split('_');
    final numerics = <int>[];
    for (var i = parts.length - 1; i >= 0; i--) {
      final n = int.tryParse(parts[i]);
      if (n == null) break;
      numerics.insert(0, n);
    }
    if (numerics.isNotEmpty) {
      double order = 0.0;
      double divisor = 1.0;
      for (final n in numerics) {
        order += n / divisor;
        divisor *= 10;
      }
      return order;
    }
    // e.g. asd-001.jpg → order by last number run in basename
    final digitRuns = RegExp(r'\d+')
        .allMatches(name)
        .map((m) => int.tryParse(m.group(0)!))
        .whereType<int>()
        .toList();
    if (digitRuns.isNotEmpty) {
      return digitRuns.last.toDouble();
    }
    return 999.0;
  }

  final pathToImage = {for (final img in images) img.path: img};
  final result = <CaseStudyImage>[];
  for (final path in _onboardingFlowFirstPaths) {
    final img = pathToImage.remove(path);
    if (img != null) result.add(img);
  }
  final rest = pathToImage.values.toList();
  rest.sort((a, b) => orderFromPath(a.path).compareTo(orderFromPath(b.path)));
  result.addAll(rest);
  return result;
}

class CaseStudyDetailScreen extends StatelessWidget {
  final PortfolioCaseStudy caseStudy;

  const CaseStudyDetailScreen({
    super.key,
    required this.caseStudy,
  });

  void _showImageDialog(
      BuildContext context, String imagePath, double wi, double he) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImage(
            imagePath: imagePath,
            animation: animation,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
        reverseTransitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    final double sectionTitleSize = isMobile ? 18 : (isTablet ? 20 : 22);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 17);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.portfolio);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: SelectableText(
          caseStudy.title,
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
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
                        horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                        vertical: isMobile ? 20 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile
                              ? double.infinity
                              : (caseStudy.id == 'asd' ? 920 : 800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    _goldGradient.createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  caseStudy.title,
                                  style: GoogleFonts.albertSans(
                                    color: _textPrimary,
                                    fontSize: isMobile
                                        ? sectionTitleSize + 4
                                        : sectionTitleSize + 6,
                                    fontWeight: FontWeight.w800,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: he * 0.014),
                            SelectableText(
                              caseStudy.subtitle,
                              style: GoogleFonts.albertSans(
                                color: _textSecondary,
                                fontSize: sectionTitleSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: he * 0.02),
                            _CaseStudyIntentLinks(
                              bodySize: bodySize,
                              onServices: () => context.go(AppRoutes.services),
                              onPortfolio: () => context.go(
                                  '${AppRoutes.portfolio}?section=featured'),
                              onContact: () => context.go(AppRoutes.contact),
                            ),
                            SizedBox(height: he * 0.022),
                            SelectableText(
                              caseStudy.overview,
                              style: GoogleFonts.albertSans(
                                color: _textSecondary,
                                fontSize: bodySize,
                                height: 1.6,
                              ),
                            ),
                            if (caseStudy.id == 'asd') ...[
                              SizedBox(height: he * 0.022),
                              const _AsdCaseStudyAtAGlance(),
                              SizedBox(height: he * 0.026),
                              _AsdCaseStudyOutline(bodySize: bodySize, he: he),
                            ],
                            if (caseStudy.designApproach != null &&
                                caseStudy.designApproach!.isNotEmpty) ...[
                              SizedBox(height: he * 0.025),
                              _DesignApproachBlock(
                                content: caseStudy.designApproach!,
                                bodySize: bodySize,
                                he: he,
                                isMobile: isMobile,
                              ),
                            ],
                            ...caseStudy.sections.expand((s) => [
                                  SizedBox(height: he * 0.025),
                                  _SectionBlock(
                                    caseStudyId: caseStudy.id,
                                    title: s.title,
                                    content: s.content,
                                    displayImages: s.displayImages,
                                    opensDesignSystemDoc:
                                        s.opensDesignSystemDoc,
                                    bodySize: bodySize,
                                    he: he,
                                    isMobile: isMobile,
                                    wi: wi,
                                    onImageTap: (imagePath) => _showImageDialog(
                                        context, imagePath, wi, he),
                                  ),
                                ]),
                            SizedBox(height: he * 0.06),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  5,
                                  (i) => Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 6 : 10),
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber.withValues(
                                              alpha: 0.7 - i * 0.08),
                                          size: isMobile ? 28 : 36,
                                        ),
                                      )),
                            ),
                            SizedBox(height: he * 0.06),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 16 : 20),
                              decoration: BoxDecoration(
                                color: _glassBase.withValues(alpha: 0.54),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      AppColors.primaryGold.withValues(alpha: 0.24),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        _goldGradient.createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: Text(
                                      'Next steps',
                                      style: GoogleFonts.albertSans(
                                        color: _textPrimary,
                                        fontSize: bodySize + 1,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Explore related service options, review more proof, or start a project conversation.',
                                    style: GoogleFonts.albertSans(
                                      color: _textSecondary,
                                      fontSize: bodySize - 1,
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      FilledButton(
                                        onPressed: () =>
                                            context.go(AppRoutes.contact),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primaryGold,
                                          foregroundColor: const Color(0xFF0B0F19),
                                        ),
                                        child: Text(
                                          'Discuss a similar project',
                                          style: GoogleFonts.albertSans(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () =>
                                            context.go(AppRoutes.services),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primaryGold,
                                          side: BorderSide(
                                            color: AppColors.primaryGold
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        child: Text(
                                          'View services',
                                          style: GoogleFonts.albertSans(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => context.go(
                                            '${AppRoutes.portfolio}?section=featured'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primaryGold,
                                          side: BorderSide(
                                            color: AppColors.primaryGold
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        child: Text(
                                          'Back to featured case studies',
                                          style: GoogleFonts.albertSans(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: he * 0.03),
                          ],
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
}

/// Quick scan line for the ASD enterprise case study (portfolio id [asd]).
class _AsdCaseStudyAtAGlance extends StatelessWidget {
  const _AsdCaseStudyAtAGlance();

  @override
  Widget build(BuildContext context) {
    const chips = [
      'Flutter + Firebase',
      'Multi-role (admin · sales · scheduler · installer · client)',
      'Workflows & dashboards',
      'Governed AI',
      'iOS · Android · Web',
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _glassBase.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.primaryGold.withValues(alpha: 0.22)),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: _glassBaseAlt.withValues(alpha: 0.54),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                t,
                style: GoogleFonts.albertSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                  letterSpacing: 0.15,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Numbered map of the eight-part ASD narrative for fast scanning.
class _AsdCaseStudyOutline extends StatelessWidget {
  const _AsdCaseStudyOutline({
    required this.bodySize,
    required this.he,
  });

  final double bodySize;
  final double he;

  static const List<String> _items = [
    'Project overview',
    'Business and problem context',
    'My role and responsibilities',
    'UX and technical challenges',
    'What I designed and built',
    'Adaptive platform (cross–form-factor)',
    'Product decisions, workflows, and AI governance',
    'Outcome, impact, and technologies',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _glassBase.withValues(alpha: 0.58),
            _glassBaseAlt.withValues(alpha: 0.52),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => _goldGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'In this case study',
              style: GoogleFonts.albertSans(
                color: _textPrimary,
                fontSize: bodySize + 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: he * 0.012),
          ...List.generate(_items.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}.',
                      style: GoogleFonts.albertSans(
                        color: _textMuted,
                        fontSize: bodySize - 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _items[i],
                      style: GoogleFonts.albertSans(
                        color: _textSecondary,
                        fontSize: bodySize - 1,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
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

class _DesignApproachBlock extends StatelessWidget {
  final String content;
  final double bodySize;
  final double he;
  final bool isMobile;

  const _DesignApproachBlock({
    required this.content,
    required this.bodySize,
    required this.he,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: _glassBase.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => _goldGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'Design approach & principles',
                  style: GoogleFonts.albertSans(
                    color: _textPrimary,
                    fontSize: bodySize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: he * 0.012),
              SelectableText(
                content,
                style: GoogleFonts.albertSans(
                  color: _textSecondary,
                  fontSize: bodySize,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClickableImage extends StatelessWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final VoidCallback onTap;

  final BoxFit fit;

  /// When true (Adaptive section), image is scaled to fit entirely inside the box (no overflow).
  final bool fitInsideContainer;

  const _ClickableImage({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.onTap,
    this.fit = BoxFit.cover,
    this.fitInsideContainer = false,
  });

  static Widget _errorPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _glassBaseAlt.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported,
            color: _textMuted,
            size: 40,
          ),
          SizedBox(height: 8),
          SelectableText(
            'Image not found',
            style: GoogleFonts.albertSans(
              color: _textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _glassBaseAlt.withValues(alpha: 0.56),
      borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
      border: Border.all(
        color: Colors.white24,
        width: 1,
      ),
    );

    final Widget inner = fitInsideContainer
        ? FittedBox(
            fit: BoxFit.contain,
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.center,
            child: Image.asset(
              imagePath,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Failed to load image: $imagePath');
                debugPrint('Error: $error');
                return SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: _errorPlaceholder(imageWidth, imageHeight),
                );
              },
            ),
          )
        : Image.asset(
            imagePath,
            width: imageWidth,
            height: imageHeight,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Failed to load image: $imagePath');
              debugPrint('Error: $error');
              return _errorPlaceholder(imageWidth, imageHeight);
            },
          );

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: imagePath,
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
            child: DecoratedBox(
              decoration: decoration,
              child: fitInsideContainer
                  ? inner
                  : SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: inner,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a case study image with optional description and corner radius caption.
class _ImageWithCaption extends StatelessWidget {
  final String imagePath;
  final String? description;
  final double imageWidth;
  final double imageHeight;
  final double bodySize;
  final VoidCallback onTap;
  final BoxFit imageFit;
  final bool imageFitInsideContainer;

  const _ImageWithCaption({
    required this.imagePath,
    this.description,
    required this.imageWidth,
    required this.imageHeight,
    required this.bodySize,
    required this.onTap,
    this.imageFit = BoxFit.cover,
    this.imageFitInsideContainer = false,
  });

  /// Display name from path: filename without extension, underscores to spaces, title case.
  static String _imageNameFromPath(String path) {
    final normalized = path.toLowerCase();

    const exactLabels = <String, String>{
      'assets/images/admin/admin_dashboard.jpeg': 'Admin Dashboard',
      'assets/images/admin/admin_home_screen.jpeg': 'Admin Home',
      'assets/images/admin/admin_user_management.jpeg': 'User Management',
      'assets/images/admin/admin_promote_to_salesrep.jpeg':
          'Promote Sales Representative',
      'assets/images/admin/admin_setting.jpeg': 'Admin Settings',
      'assets/images/admin/admin_amy_manager.jpeg': 'Amy Manager',
      'assets/images/admin/admin_chat_with_amy.jpeg': 'Admin Chat with Amy',
      'assets/images/admin/admin_ai_knowledge_base.jpeg': 'AI Knowledge Base',
      'assets/images/admin/admin_trending_material.jpeg': 'Trending Materials',
      'assets/images/admin/admin_new_material.jpeg': 'New Materials',
      'assets/images/admin/admin_popular_material.jpeg': 'Popular Materials',
      'assets/images/admin/admin_recommended_image.jpeg':
          'Recommended Materials',
      'assets/images/sales_rep/salesrep_dashboard.png': 'Sales Dashboard',
      'assets/images/sales_rep/salesrep_home.png': 'Sales Home',
      'assets/images/sales_rep/salesrep_client.png': 'Client Management',
      'assets/images/sales_rep/salesrep_project.png': 'Project Pipeline',
      'assets/images/sales_rep/create_invoice_01.png': 'Create Invoice',
      'assets/images/sales_rep/performance analytics.png':
          'Performance Analytics',
      'assets/images/scheduler/scheduler dashboard.png': 'Scheduler Dashboard',
      'assets/images/scheduler/scheduler dashboard 01.png':
          'Scheduler Planning',
      'assets/images/scheduler/create event.png': 'Create Event',
      'assets/images/scheduler/date picker.png': 'Date Picker',
      'assets/images/scheduler/time picker.png': 'Time Picker',
      'assets/images/installer/installer dashboard.png': 'Installer Dashboard',
      'assets/images/installer/installer home screen.png': 'Installer Home',
      'assets/images/installer/installer on the map.png': 'Installer Live Map',
      'assets/images/installer/job history.png': 'Job History',
      'assets/images/installer/installer profile.png': 'Installer Profile',
    };
    final exact = exactLabels[normalized];
    if (exact != null) return exact;

    if (normalized.contains('sales')) return 'Sales Experience';
    if (normalized.contains('scheduler')) return 'Scheduler Experience';
    if (normalized.contains('installer')) return 'Installer Experience';
    if (normalized.contains('admin')) return 'Admin Experience';
    if (normalized.contains('material')) return 'Materials Management';
    if (normalized.contains('seasonal')) return 'Seasonal Campaign';
    if (normalized.contains('design_system')) return 'Design System';

    final name = path
        .split('/')
        .last
        .replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
    return name
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final displayDescription = (description != null && description!.isNotEmpty)
        ? description!
        : _imageNameFromPath(imagePath);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ClickableImage(
          imagePath: imagePath,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          onTap: onTap,
          fit: imageFit,
          fitInsideContainer: imageFitInsideContainer,
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectableText(
                displayDescription,
                style: GoogleFonts.albertSans(
                  color: _textSecondary,
                  fontSize: bodySize * 0.9,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imagePath;
  final Animation<double> animation;

  const _FullScreenImage({
    required this.imagePath,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: Hero(
                tag: imagePath,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: _glassBase.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: _textMuted,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            SelectableText(
                              'Image not found',
                              style: GoogleFonts.albertSans(
                                color: _textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: _textPrimary,
                  size: 32,
                ),
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                  backgroundColor: _glassBase.withValues(alpha: 0.7),
                  shape: CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String caseStudyId;
  final String title;
  final String content;
  final List<CaseStudyImage> displayImages;
  final bool opensDesignSystemDoc;
  final double bodySize;
  final double he;
  final bool isMobile;
  final double wi;
  final Function(String) onImageTap;

  const _SectionBlock({
    required this.caseStudyId,
    required this.title,
    required this.content,
    required this.displayImages,
    required this.opensDesignSystemDoc,
    required this.bodySize,
    required this.he,
    required this.isMobile,
    required this.wi,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: title == 'The Solution'
                  ? [
                      _glassBase.withValues(alpha: 0.62),
                      _glassBaseAlt.withValues(alpha: 0.58),
                      const Color(0xFF35222A).withValues(alpha: 0.56),
                    ]
                  : [
                      _glassBase.withValues(alpha: 0.62),
                      _glassBaseAlt.withValues(alpha: 0.58),
                      _glassBase.withValues(alpha: 0.52),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: title == 'The Solution'
                  ? AppColors.primaryGold.withValues(alpha: 0.28)
                  : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: ShaderMask(
                  shaderCallback: (bounds) => _goldGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    title,
                    style: GoogleFonts.albertSans(
                      color: _textPrimary,
                      fontSize: bodySize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: he * 0.015),
              SelectableText(
                content,
                style: GoogleFonts.albertSans(
                  color: _textSecondary,
                  fontSize: bodySize,
                  height: 1.6,
                ),
              ),
              if (opensDesignSystemDoc &&
                  PortfolioData.caseStudyHasDesignSystemDoc(caseStudyId)) ...[
                SizedBox(height: he * 0.02),
                FilledButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.portfolioCaseStudyDesignSystemPath(caseStudyId),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: const Color(0xFF0B0F19),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: Text(
                    'Open design system (full document)',
                    style: GoogleFonts.albertSans(
                      fontWeight: FontWeight.w600,
                      fontSize: bodySize,
                    ),
                  ),
                ),
              ],
              if (displayImages.isNotEmpty) ...[
                SizedBox(height: he * 0.02),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final List<CaseStudyImage> sortedImages =
                        caseStudyId == 'rose-chat-seasonal-campaign-engine' &&
                                title == 'Seasonal campaign UI'
                            ? List<CaseStudyImage>.from(displayImages)
                            : _sortImagesByTrailingNumber(displayImages);
                    final double availableWidth =
                        constraints.maxWidth.isFinite &&
                                constraints.maxWidth > 0
                            ? constraints.maxWidth
                            : wi;
                    final bool isDesignSystem =
                        title == 'Design System (v3.0.11)';
                    final bool isSolutionSection = title == 'The Solution';
                    // Firestore title typos still get correct layout if paths are under asd_app_adaptive.
                    final bool isAdaptivePlatformSection =
                        CaseStudySection.matchesAdaptivePlatformSection(
                      title,
                      displayImages.map((i) => i.path),
                    );

                    double imageWidth;
                    double imageHeight;
                    int crossAxisCount;

                    if (isDesignSystem) {
                      imageHeight = isMobile ? 240 : 320;
                      crossAxisCount =
                          isMobile ? 1 : (availableWidth > 900 ? 3 : 2);
                      imageWidth = isMobile
                          ? availableWidth
                          : (availableWidth - (crossAxisCount - 1) * 12) /
                              crossAxisCount;
                    } else if (isAdaptivePlatformSection) {
                      // Landscape assets 2720×1504 — full width on phone; capped height on wider layouts.
                      final double aspect = kAdaptivePlatformAspectRatio;
                      crossAxisCount = 1;
                      imageWidth = availableWidth;
                      imageHeight = imageWidth / aspect;
                      if (!isMobile) {
                        final double maxH = availableWidth > 960 ? 520 : 440;
                        if (imageHeight > maxH) {
                          imageHeight = maxH;
                          imageWidth = imageHeight * aspect;
                        }
                      }
                    } else if (isSolutionSection) {
                      crossAxisCount = isMobile
                          ? 2
                          : (availableWidth > 900
                              ? 4
                              : (availableWidth > 600 ? 3 : 2));
                      final double spacing = 12;
                      final double totalGaps = (crossAxisCount - 1) * spacing;
                      final double cellWidth =
                          (availableWidth - totalGaps) / crossAxisCount;
                      imageWidth = cellWidth;
                      imageHeight = cellWidth * (2796 / 1290);
                    } else {
                      imageHeight = isMobile
                          ? 450
                          : (availableWidth > 1200
                              ? 550
                              : (availableWidth > 800 ? 500 : 450));
                      imageWidth = imageHeight * (1290 / 2796);
                      crossAxisCount = isMobile
                          ? 1
                          : (availableWidth > 1200
                              ? 4
                              : (availableWidth > 900 ? 3 : 2));
                    }

                    final double spacing = 12;
                    final bool showOneByOneCentered = isMobile &&
                        !isDesignSystem &&
                        !isSolutionSection &&
                        !isAdaptivePlatformSection;
                    final bool hasDescriptions = sortedImages.any((img) =>
                        img.description != null && img.description!.isNotEmpty);

                    Widget buildImageItem(
                      CaseStudyImage item, {
                      BoxFit fit = BoxFit.cover,
                      bool fitInside = false,
                    }) {
                      return _ImageWithCaption(
                        imagePath: item.path,
                        description: item.description,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                        bodySize: bodySize,
                        onTap: () => onImageTap(item.path),
                        imageFit: fit,
                        imageFitInsideContainer: fitInside,
                      );
                    }

                    if (isAdaptivePlatformSection) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(sortedImages.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  index < sortedImages.length - 1 ? spacing : 0,
                            ),
                            child: Center(
                              child: buildImageItem(
                                sortedImages[index],
                                fit: BoxFit.contain,
                                fitInside: true,
                              ),
                            ),
                          );
                        }),
                      );
                    }

                    if (showOneByOneCentered) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(sortedImages.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  index < sortedImages.length - 1 ? spacing : 0,
                            ),
                            child: Center(
                              child: buildImageItem(sortedImages[index]),
                            ),
                          );
                        }),
                      );
                    }

                    if (isSolutionSection && sortedImages.length > 1) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: imageWidth /
                              (imageHeight + (hasDescriptions ? 88 : 48)),
                        ),
                        itemCount: sortedImages.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: buildImageItem(sortedImages[index]),
                          );
                        },
                      );
                    }

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: isSolutionSection
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      children: List.generate(sortedImages.length, (index) {
                        return buildImageItem(sortedImages[index]);
                      }),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseStudyIntentLinks extends StatelessWidget {
  const _CaseStudyIntentLinks({
    required this.bodySize,
    required this.onServices,
    required this.onPortfolio,
    required this.onContact,
  });

  final double bodySize;
  final VoidCallback onServices;
  final VoidCallback onPortfolio;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: onServices,
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
          child: Text(
            'Related Flutter and product design services',
            style: GoogleFonts.albertSans(
              color: AppColors.primaryGold,
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextButton(
          onPressed: onPortfolio,
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
          child: Text(
            'More featured case studies',
            style: GoogleFonts.albertSans(
              color: AppColors.primaryGold,
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextButton(
          onPressed: onContact,
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
          child: Text(
            'Discuss a similar project scope',
            style: GoogleFonts.albertSans(
              color: AppColors.primaryGold,
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
