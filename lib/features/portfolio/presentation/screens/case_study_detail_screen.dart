import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';

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
                          SizedBox(height: he * 0.04),
                          ...caseStudy.sections.map(
                            (s) => _SectionBlock(
                              title: s.title,
                              content: s.content,
                              imagePaths: s.imagePaths,
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              wi: wi,
                              onImageHover: (imagePath) => _showImageDialog(context, imagePath, wi, he),
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
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: imageWidth,
              height: imageHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(40),
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
                      borderRadius: BorderRadius.circular(40),
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
  final List<String>? imagePaths;
  final double bodySize;
  final double he;
  final bool isMobile;
  final double wi;
  final Function(String) onImageHover;

  const _SectionBlock({
    required this.title,
    required this.content,
    this.imagePaths,
    required this.bodySize,
    required this.he,
    required this.isMobile,
    required this.wi,
    required this.onImageHover,
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
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
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
              if (imagePaths != null && imagePaths!.isNotEmpty) ...[
                SizedBox(height: he * 0.02),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    // Design system images: larger landscape size, other roles: mobile portrait size
                    final bool isDesignSystem = title == 'Design System (v3.0.11)';
                    
                    double imageWidth;
                    double imageHeight;
                    int crossAxisCount;
                    
                    if (isDesignSystem) {
                      // Design system: landscape format
                      imageHeight = isMobile ? 240 : 320;
                      crossAxisCount = isMobile ? 1 : (availableWidth > 900 ? 3 : 2);
                      imageWidth = isMobile 
                          ? availableWidth 
                          : (availableWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
                    } else {
                      // Role images: portrait mobile format (standing rectangle)
                      // Actual image dimensions: 1290 x 2796
                      // Aspect ratio: 1290/2796 ≈ 0.4614 (width:height)
                      // Calculate height first, then width based on actual aspect ratio
                      imageHeight = isMobile 
                          ? 450  // Mobile: larger height
                          : (availableWidth > 1200 ? 550 : (availableWidth > 800 ? 500 : 450));
                      // Use actual image aspect ratio (1290/2796 = 0.4614)
                      imageWidth = imageHeight * (1290 / 2796); // Exact aspect ratio from image dimensions
                      crossAxisCount = isMobile 
                          ? 2 
                          : (availableWidth > 1200 ? 4 : (availableWidth > 900 ? 3 : 2));
                    }
                    
                    final double spacing = 12;
                    
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.start,
                      children: imagePaths!.map((imagePath) {
                        return _ClickableImage(
                          imagePath: imagePath,
                          imageWidth: imageWidth,
                          imageHeight: imageHeight,
                          onTap: () => onImageHover(imagePath),
                        );
                      }).toList(),
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
