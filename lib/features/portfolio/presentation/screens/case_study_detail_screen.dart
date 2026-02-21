import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';

/// Corner radius (in logical pixels) used for all case study images in this screen.
const double kCaseStudyImageCornerRadius = 30;

/// Onboarding flow order: English (1st), Persian (2nd), Turkish (3rd), then rest by trailing number.
const List<String> _onboardingFlowFirstPaths = [
  'assets/images/on_boarding_image/on_boarding_en_1.png',  // 1st: English
  'assets/images/on_boarding_image/on_boarding_fa_2.png',  // 2nd: Persian
  'assets/images/on_boarding_image/on_boarding_tr_3.png', // 3rd: Turkish
];

/// Order images: first the three onboarding flows (EN, FA, TR), then rest by numbers at end of filename.
List<CaseStudyImage> _sortImagesByTrailingNumber(List<CaseStudyImage> images) {
  double orderFromPath(String path) {
    final name = path.split('/').last.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '');
    final parts = name.split('_');
    final numerics = <int>[];
    for (var i = parts.length - 1; i >= 0; i--) {
      final n = int.tryParse(parts[i]);
      if (n == null) break;
      numerics.insert(0, n);
    }
    if (numerics.isEmpty) return 999.0;
    double order = 0.0;
    double divisor = 1.0;
    for (final n in numerics) {
      order += n / divisor;
      divisor *= 10;
    }
    return order;
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

  void _showImageDialog(BuildContext context, String imagePath, double wi, double he) {
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber[100]),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
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
          SafeArea(
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
                        maxWidth: isMobile ? double.infinity : 800,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            caseStudy.subtitle,
                            style: GoogleFonts.albertSans(
                              color: ColorManager.orange,
                              fontSize: sectionTitleSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: he * 0.02),
                          SelectableText(
                            caseStudy.overview,
                            style: GoogleFonts.albertSans(
                              color: Colors.white,
                              fontSize: bodySize,
                              height: 1.6,
                            ),
                          ),
                          if (caseStudy.designApproach != null && caseStudy.designApproach!.isNotEmpty) ...[
                            SizedBox(height: he * 0.03),
                            _DesignApproachBlock(
                              content: caseStudy.designApproach!,
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                            ),
                          ],
                          SizedBox(height: he * 0.04),
                          ...caseStudy.sections.map(
                            (s) => _SectionBlock(
                              title: s.title,
                              content: s.content,
                              displayImages: s.displayImages,
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              wi: wi,
                              onImageTap: (imagePath) => _showImageDialog(context, imagePath, wi, he),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorManager.orange.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                'Design approach & principles',
                style: GoogleFonts.albertSans(
                  color: ColorManager.orange,
                  fontSize: bodySize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: he * 0.012),
              SelectableText(
                content,
                style: GoogleFonts.albertSans(
                  color: Colors.white.withValues(alpha: 0.9),
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

  const _ClickableImage({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: imagePath,
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
            child: Container(
              width: imageWidth,
              height: imageHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Image.asset(
                imagePath,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Failed to load image: $imagePath');
                  debugPrint('Error: $error');
                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kCaseStudyImageCornerRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          SelectableText(
                            'Image not found',
                            style: GoogleFonts.albertSans(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  const _ImageWithCaption({
    required this.imagePath,
    this.description,
    required this.imageWidth,
    required this.imageHeight,
    required this.bodySize,
    required this.onTap,
  });

  /// Display name from path: filename without extension, underscores to spaces, title case.
  static String _imageNameFromPath(String path) {
    final name = path.split('/').last.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '');
    return name.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final displayDescription = (description != null && description!.isNotEmpty) ? description! : _imageNameFromPath(imagePath);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ClickableImage(
          imagePath: imagePath,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          onTap: onTap,
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
                  color: Colors.white,
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
      onTap: () => Navigator.of(context).pop(),
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
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            SelectableText(
                              'Image not found',
                              style: GoogleFonts.albertSans(
                                color: Colors.white,
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
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
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
  final String title;
  final String content;
  final List<CaseStudyImage> displayImages;
  final double bodySize;
  final double he;
  final bool isMobile;
  final double wi;
  final Function(String) onImageTap;

  const _SectionBlock({
    required this.title,
    required this.content,
    required this.displayImages,
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
          margin: EdgeInsets.only(bottom: he * 0.03),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: title == 'The Solution'
                  ? [
                      const Color(0xFFD81B60).withValues(alpha: 0.08),
                      const Color(0xFFB0154F).withValues(alpha: 0.05),
                      const Color(0xFFD81B60).withValues(alpha: 0.06),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.12),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: title == 'The Solution'
                  ? const Color(0xFFD81B60).withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: -5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                title,
                style: GoogleFonts.albertSans(
                  color: ColorManager.orange,
                  fontSize: bodySize + 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: he * 0.015),
              SelectableText(
                content,
                style: GoogleFonts.albertSans(
                  color: Colors.white,
                  fontSize: bodySize,
                  height: 1.6,
                ),
              ),
              if (displayImages.isNotEmpty) ...[
                SizedBox(height: he * 0.02),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final List<CaseStudyImage> sortedImages = _sortImagesByTrailingNumber(displayImages);
                    final double availableWidth = constraints.maxWidth;
                    final bool isDesignSystem = title == 'Design System (v3.0.11)';
                    final bool isSolutionSection = title == 'The Solution';
                    
                    double imageWidth;
                    double imageHeight;
                    int crossAxisCount;
                    
                    if (isDesignSystem) {
                      imageHeight = isMobile ? 240 : 320;
                      crossAxisCount = isMobile ? 1 : (availableWidth > 900 ? 3 : 2);
                      imageWidth = isMobile 
                          ? availableWidth 
                          : (availableWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
                    } else if (isSolutionSection) {
                      crossAxisCount = isMobile ? 2 : (availableWidth > 900 ? 4 : (availableWidth > 600 ? 3 : 2));
                      final double spacing = 12;
                      final double totalGaps = (crossAxisCount - 1) * spacing;
                      final double cellWidth = (availableWidth - totalGaps) / crossAxisCount;
                      imageWidth = cellWidth;
                      imageHeight = cellWidth * (2796 / 1290);
                    } else {
                      imageHeight = isMobile 
                          ? 450
                          : (availableWidth > 1200 ? 550 : (availableWidth > 800 ? 500 : 450));
                      imageWidth = imageHeight * (1290 / 2796);
                      crossAxisCount = isMobile 
                          ? 1
                          : (availableWidth > 1200 ? 4 : (availableWidth > 900 ? 3 : 2));
                    }
                    
                    final double spacing = 12;
                    final bool showOneByOneCentered = isMobile && !isDesignSystem && !isSolutionSection;
                    final bool hasDescriptions = sortedImages.any((img) => img.description != null && img.description!.isNotEmpty);

                    Widget buildImageItem(CaseStudyImage item) {
                      return _ImageWithCaption(
                        imagePath: item.path,
                        description: item.description,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                        bodySize: bodySize,
                        onTap: () => onImageTap(item.path),
                      );
                    }

                    if (showOneByOneCentered) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(sortedImages.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < sortedImages.length - 1 ? spacing : 0,
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
                          childAspectRatio: imageWidth / (imageHeight + (hasDescriptions ? 88 : 48)),
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
                      alignment: isSolutionSection ? WrapAlignment.center : WrapAlignment.start,
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
