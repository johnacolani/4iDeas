import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_router.dart';
import '../core/design_system/theme.dart';
import '../core/home_warm_colors.dart';
import '../core/utils/file_download.dart';

class QrCodeGeneratorScreen extends StatefulWidget {
  const QrCodeGeneratorScreen({super.key});

  @override
  State<QrCodeGeneratorScreen> createState() => _QrCodeGeneratorScreenState();
}

class _QrCodeGeneratorScreenState extends State<QrCodeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  static const String _defaultWebsiteUrl = 'https://4ideasapp.com';

  static const Color _kAppBarDarkBlue = Color(0xFF0F2744);
  static const Color _kScaffoldDark = Color(0xFF070F1C);

  late final AnimationController _bubbleController;
  final TextEditingController _textController = TextEditingController();
  String _qrData = _defaultWebsiteUrl;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    final value = _textController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or a URL')),
      );
      return;
    }

    setState(() => _qrData = value);
  }

  Future<void> _downloadQrCode() async {
    final value = _textController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or a URL')),
      );
      return;
    }

    setState(() {
      _qrData = value;
      _isDownloading = true;
    });

    try {
      final painter = QrPainter(
        data: value,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );
      final byteData = await painter.toImageData(
        1024,
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw StateError('Could not render QR code image');
      }

      final bytes = Uint8List.view(byteData.buffer);
      final downloaded = await downloadBytes(
        filename: '4ideas-qr-code.png',
        bytes: bytes,
        mimeType: 'image/png',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloaded
                ? 'QR code downloaded'
                : 'Download is available from the web version of this page',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not download the QR code')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 640;
    final bool twoColumn = width >= 900;
    final double qrSize = isMobile ? 220 : 260;

    final double hp = isMobile ? 16.0 : 28.0;
    final EdgeInsets safePad = MediaQuery.paddingOf(context);
    final double viewportInner =
        width - safePad.horizontal - hp * 2;
    const double maxContentBlock = 1180;
    final double blockW =
        twoColumn ? math.min(maxContentBlock, viewportInner.clamp(0.0, 1e9)) : 0;
    final double trailing =
        twoColumn ? (viewportInner - blockW).clamp(0.0, 1e9) : 0;
    const double animBleed = 44;
    final double overlayAnimWidthRaw =
        trailing >= 32 ? math.min(340.0, trailing + animBleed) : 0.0;
    /// In the gutter between content and screen edge; also shifted 5% viewport width left.
    final double overlayRightInset = safePad.right + 28 + width * 0.05;
    final double contentRightEdge = safePad.left + hp + blockW;
    final double maxAnimWidth =
        width - overlayRightInset - contentRightEdge + animBleed;
    final double overlayAnimWidth = overlayAnimWidthRaw > 0 && maxAnimWidth >= 72
        ? math.min(overlayAnimWidthRaw, maxAnimWidth)
        : 0.0;

    return Scaffold(
      backgroundColor: _kScaffoldDark,
      appBar: AppBar(
        backgroundColor: _kAppBarDarkBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          tooltip: 'Back to home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('QR Code Generator'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _QrGeneratorBackgroundPainter(
                    progress: _bubbleController.value,
                  ),
                );
              },
            ),
          ),
          if (twoColumn && overlayAnimWidth >= 72)
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double topPad = 36;
                    final double h =
                        math.min(480.0, constraints.maxHeight - topPad - 28);
                    if (h < 120) return const SizedBox.shrink();
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: overlayRightInset,
                          top: topPad,
                          width: overlayAnimWidth,
                          height: h,
                          child: ExcludeSemantics(
                            child: _QrDesignDevAccentGraphic(
                              animation: _bubbleController,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 28,
                  vertical: isMobile ? 16 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: twoColumn ? 1180 : 560,
                  ),
                  child: twoColumn
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final double w = constraints.maxWidth;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 46,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: math.min(520.0, w * 0.46),
                                      ),
                                      child: _buildPromoBanner(
                                        context,
                                        isMobile: false,
                                        largeHeadline: true,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 54,
                                  child: _buildQrGeneratorCard(
                                    context,
                                    isMobile: false,
                                    qrSize: qrSize,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPromoBanner(
                              context,
                              isMobile: isMobile,
                              largeHeadline: false,
                            ),
                            const SizedBox(height: 40),
                            _buildQrGeneratorCard(
                              context,
                              isMobile: isMobile,
                              qrSize: qrSize,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrGeneratorCard(
    BuildContext context, {
    required bool isMobile,
    required double qrSize,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              color: HomeWarmColors.sectionAccent,
              size: 42,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              'Generate Your QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: const Color(0xFF111827),
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a link, phone number, email, or any text.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: const Color(0xFF64748B),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              label: Transform.translate(
                offset: const Offset(0, -13),
                child: _buildTextFieldLabel(),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: _defaultWebsiteUrl,
              hintStyle: GoogleFonts.roboto(
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(
                Icons.link_rounded,
                color: Color(0xFF64748B),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF475569),
                  width: 1.6,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generateQrCode(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _generateQrCode,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                textStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isDownloading ? null : _downloadQrCode,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                _isDownloading ? 'Preparing PNG...' : 'Download QR Code',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111827),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                textStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            label: 'QR code for $_qrData',
            image: true,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: qrSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            _qrData,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(
    BuildContext context, {
    required bool isMobile,
    required bool largeHeadline,
  }) {
    const TextAlign textAlign = TextAlign.start;
    const WrapAlignment wrapAlign = WrapAlignment.start;
    final double headlineSize = largeHeadline ? 36 : (isMobile ? 26 : 32);
    final double subSize = isMobile ? 16 : 17;
    final double footerSize = isMobile ? 14.5 : 15.5;

    return Semantics(
      container: true,
      label:
          'Product Design, MVP. Flutter App Development for Startups and Businesses. '
          'We design and build production-ready Flutter apps for iOS, Android, and Web, '
          'from MVP idea to App Store launch. '
          'Flutter, Firebase, Product Design, AI features, admin dashboards, role-based apps, '
          'and full product delivery.',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 28,
              vertical: isMobile ? 22 : 28,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.36),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                  const Color(0xFF38BDF8).withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _shimmerGoldHeadline(
                  'Product Design, MVP',
                  headlineSize,
                  textAlign,
                ),
                SizedBox(height: largeHeadline ? 12 : 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Flutter App Development for',
                    maxLines: 1,
                    softWrap: false,
                    textAlign: textAlign,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: headlineSize,
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                    ),
                  ),
                ),
                SizedBox(height: largeHeadline ? 12 : 10),
                _shimmerGoldHeadline(
                  'Startups & Businesses',
                  headlineSize,
                  textAlign,
                ),
                SizedBox(height: largeHeadline ? 26 : 20),
                Text(
                  'We design and build production-ready Flutter apps for iOS, '
                  'Android, and Web, from MVP idea to App Store launch.',
                  textAlign: textAlign,
                  style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: largeHeadline ? (subSize + 1) : subSize,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                  ),
                ),
                SizedBox(height: largeHeadline ? 20 : 16),
                Text(
                  'Flutter, Firebase, Product Design, AI features, admin dashboards, '
                  'role-based apps, and full product delivery.',
                  textAlign: textAlign,
                  style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: largeHeadline ? (footerSize + 0.5) : footerSize,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: largeHeadline ? 22 : 18),
                Wrap(
                  alignment: wrapAlign,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Tooltip(
                      message: 'Contact us about Flutter development',
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.contact),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primaryGold,
                          size: 18,
                        ),
                        label: Text(
                          'Start a project',
                          style: GoogleFonts.roboto(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'View services',
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.services),
                        child: Text(
                          'Services',
                          style: GoogleFonts.roboto(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerGoldHeadline(
    String text,
    double fontSize,
    TextAlign textAlign,
  ) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, _) {
        final t = _bubbleController.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.15 + t * 2.3, 0),
              end: Alignment(0.05 + t * 2.3, 0),
              colors: [
                AppColors.primaryGold,
                const Color(0xFFFFE08A),
                AppColors.primaryGoldDark,
              ],
              stops: const [0.28, 0.52, 0.74],
            ).createShader(bounds);
          },
          child: Text(
            text,
            textAlign: textAlign,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        'Text or URL',
        style: GoogleFonts.roboto(
          color: const Color(0xFF4B5563),
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Decorative motion in viewport gutter only — does not participate in layout.
class _QrDesignDevAccentGraphic extends StatelessWidget {
  const _QrDesignDevAccentGraphic({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _QrDesignDevMotionPainter(progress: animation.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _QrDesignDevMotionPainter extends CustomPainter {
  _QrDesignDevMotionPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide < 8) return;

    final double w = size.width;
    final double h = size.height;
    final double t = progress * math.pi * 2;

    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.055);
    for (var gx = 0.0; gx < w; gx += 24) {
      canvas.drawLine(Offset(gx, 0), Offset(gx, h), gridPaint);
    }
    for (var gy = 0.0; gy < h; gy += 24) {
      canvas.drawLine(Offset(0, gy), Offset(w, gy), gridPaint);
    }

    final double cx = w * 0.52;
    final double cy = h * 0.48;

    void paintBoard({
      required double ox,
      required double oy,
      required double bw,
      required double bh,
      required double rotation,
      required double strokeOpacity,
      required Color strokeColor,
      required double fillOpacity,
    }) {
      canvas.save();
      canvas.translate(cx + ox, cy + oy);
      canvas.rotate(rotation);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
        const Radius.circular(14),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = Colors.white.withValues(alpha: fillOpacity),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = strokeColor.withValues(alpha: strokeOpacity),
      );
      canvas.restore();
    }

    paintBoard(
      ox: -14,
      oy: 22,
      bw: w * 0.72,
      bh: h * 0.62,
      rotation: -0.14 + 0.035 * math.sin(t * 0.9),
      strokeOpacity: 0.38,
      strokeColor: const Color(0xFF38BDF8),
      fillOpacity: 0.055,
    );

    paintBoard(
      ox: 10,
      oy: 12,
      bw: w * 0.68,
      bh: h * 0.56,
      rotation: 0.11 + 0.04 * math.sin(t * 1.1 + 1),
      strokeOpacity: 0.32,
      strokeColor: AppColors.primaryGold,
      fillOpacity: 0.065,
    );

    canvas.save();
    canvas.translate(cx - 4, cy - 8);
    canvas.rotate(-0.06 + 0.025 * math.sin(t * 0.85 + 0.5));

    final RRect phoneOuter = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.62, height: h * 0.68),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      phoneOuter,
      Paint()..color = Colors.white.withValues(alpha: 0.13),
    );
    canvas.drawRRect(
      phoneOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.38),
    );

    final RRect screenRect = phoneOuter.deflate(10);
    canvas.drawRRect(
      screenRect,
      Paint()
        ..color = const Color(0xFF0F2744).withValues(alpha: 0.52),
    );

    final double barH = screenRect.height * 0.085;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          screenRect.left + 8,
          screenRect.top + 8,
          screenRect.width - 16,
          barH,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.white.withValues(
          alpha: 0.16 + 0.05 * math.sin(t),
        ),
    );

    final Paint slotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.11);
    for (var i = 0; i < 4; i++) {
      final double dy =
          screenRect.top + barH + 18 + i * (screenRect.height * 0.125);
      final double slotW =
          screenRect.width - 24 - (i.isOdd ? 22.0 : 0.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            screenRect.left + 12,
            dy,
            slotW,
            screenRect.height * 0.055,
          ),
          const Radius.circular(5),
        ),
        slotPaint,
      );
    }

    final double qrSide =
        math.min(screenRect.width, screenRect.height) * 0.21;
    final double qrLeft = screenRect.right - qrSide - 14;
    final double qrTop = screenRect.bottom - qrSide - 14;
    final double cell = qrSide / 7;
    final Paint qrDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.34);
    for (var ri = 0; ri < 7; ri++) {
      for (var ci = 0; ci < 7; ci++) {
        final double wave =
            math.sin(t * 1.25 + ri * 0.55 + ci * 0.48);
        final bool anchor = (ri < 2 && ci < 2) ||
            (ri < 2 && ci > 4) ||
            (ri > 4 && ci < 2);
        final bool shimmer = wave > 0.35;
        if (anchor || shimmer || (ri + ci) % 4 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                qrLeft + ci * cell,
                qrTop + ri * cell,
                cell * 0.82,
                cell * 0.82,
              ),
              const Radius.circular(1.2),
            ),
            qrDot,
          );
        }
      }
    }

    canvas.restore();

    final double orbitR = math.min(w, h) * 0.36;
    final List<Color> orbColors = [
      AppColors.primaryGold,
      const Color(0xFF38BDF8),
      const Color(0xFFA78BFA),
      const Color(0xFF34D399),
      const Color(0xFFE2E8F0),
    ];

    for (var i = 0; i < orbColors.length; i++) {
      final double ang = t * (0.32 + i * 0.085) + i * 1.15;
      final double ox =
          cx + math.cos(ang) * orbitR * (0.52 + 0.07 * i);
      final double oy =
          cy + math.sin(ang) * orbitR * (0.44 + 0.06 * i);
      final double rad = 3.6 + (i.isEven ? 2.2 : 0);
      canvas.drawCircle(
        Offset(ox, oy),
        rad + 5,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
          ..color = orbColors[i].withValues(alpha: 0.28),
      );
      canvas.drawCircle(
        Offset(ox, oy),
        rad,
        Paint()..color = orbColors[i].withValues(alpha: 0.82),
      );
    }

    final Paint bracketPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color =
          Colors.white.withValues(alpha: 0.16 + 0.06 * math.sin(t * 2));
    final double bx = w * 0.06;
    final double by = h * 0.71;
    final double bh = h * 0.13;
    canvas.drawPath(
      Path()
        ..moveTo(bx + 11, by)
        ..lineTo(bx, by)
        ..lineTo(bx, by + bh)
        ..lineTo(bx + 11, by + bh),
      bracketPaint,
    );
    final double bx2 = w * 0.28;
    canvas.drawPath(
      Path()
        ..moveTo(bx2 - 11, by)
        ..lineTo(bx2, by)
        ..lineTo(bx2, by + bh)
        ..lineTo(bx2 - 11, by + bh),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrDesignDevMotionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _QrGeneratorBackgroundPainter extends CustomPainter {
  const _QrGeneratorBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF050B14),
          Color(0xFF0C1629),
          Color(0xFF111827),
          Color(0xFF070F1C),
        ],
        stops: [0.0, 0.34, 0.68, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final leftRadialPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-1.05, 0.40),
        radius: 1.48,
        focal: const Alignment(-0.98, 0.38),
        focalRadius: 0.06,
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.44),
          const Color(0xFF38BDF8).withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.36, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, leftRadialPaint);

    final bubbles = <_QrBackgroundBubble>[
      const _QrBackgroundBubble(
        alignment: Alignment(-0.88, -0.72),
        radius: 140,
        color: Color(0xFF2563EB),
        alpha: 0.14,
        drift: 18,
      ),
      const _QrBackgroundBubble(
        alignment: Alignment(0.86, -0.58),
        radius: 170,
        color: Color(0xFFD97706),
        alpha: 0.10,
        drift: 24,
      ),
      const _QrBackgroundBubble(
        alignment: Alignment(-0.70, 0.76),
        radius: 190,
        color: Color(0xFF475569),
        alpha: 0.12,
        drift: 22,
      ),
      const _QrBackgroundBubble(
        alignment: Alignment(0.78, 0.62),
        radius: 130,
        color: Color(0xFF6366F1),
        alpha: 0.11,
        drift: 20,
      ),
    ];

    for (var index = 0; index < bubbles.length; index++) {
      final bubble = bubbles[index];
      final baseOffset = bubble.alignment.alongSize(size);
      final phase = (progress * math.pi * 2) + (index * math.pi / 2);
      final animatedOffset = Offset(
        math.cos(phase) * bubble.drift,
        math.sin(phase) * bubble.drift,
      );
      final center = Offset(
            size.width / 2 + baseOffset.dx / 2,
            size.height / 2 + baseOffset.dy / 2,
          ) +
          animatedOffset;

      final paint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
        ..color = bubble.color.withValues(alpha: bubble.alpha);
      canvas.drawCircle(center, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _QrGeneratorBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _QrBackgroundBubble {
  const _QrBackgroundBubble({
    required this.alignment,
    required this.radius,
    required this.color,
    required this.alpha,
    required this.drift,
  });

  final Alignment alignment;
  final double radius;
  final Color color;
  final double alpha;
  final double drift;
}
