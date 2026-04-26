import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/responsive.dart';
import '../home_warm_colors.dart';

/// Home row: iOS / Android / Web / desktop with logos + short line each.
/// Layout is bounded so text never triggers [RenderFlex] overflow in the tile
/// (common with [FittedBox]+[Column] on web at larger text scale).
class PlatformProofChips extends StatelessWidget {
  const PlatformProofChips({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  final bool isMobile;
  final bool isTablet;

  static const List<({String label, String subtitle, String asset})> _items = [
    (
      label: 'iOS',
      subtitle: 'Native-quality experience',
      asset: 'assets/platforms/ios.png',
    ),
    (
      label: 'Android',
      subtitle: 'One codebase, broad reach',
      asset: 'assets/platforms/android.png',
    ),
    (
      label: 'Web',
      subtitle: 'Fast and responsive web apps',
      asset: 'assets/platforms/web.png',
    ),
    (
      label: 'macOS',
      subtitle: 'Desktop apps for modern teams',
      asset: 'assets/platforms/macos.png',
    ),
    (
      label: 'Windows',
      subtitle: 'Cross-platform productivity',
      asset: 'assets/platforms/windows.png',
    ),
    (
      label: 'Linux',
      subtitle: 'Stable apps for power users',
      asset: 'assets/platforms/linux.png',
    ),
  ];

  double get _chipW => isMobile ? 206.0 : 236.0;
  double get _chipH => isMobile ? 76.0 : 84.0;

  @override
  Widget build(BuildContext context) {
    final bool disableMotion = MediaQuery.disableAnimationsOf(context);
    // Keep chips at a readable lane width on web.
    final double laneWidth = kIsWeb
        ? MediaQuery.sizeOf(context).width * (2 / 3)
        : double.infinity;

    // Enable marquee on web when motion is allowed.
    if (kIsWeb && !disableMotion) {
      return SizedBox(
        width: laneWidth,
        child: _PlatformProofChipsAutoScroll(
          isMobile: isMobile,
          isTablet: isTablet,
          items: _items,
          chipW: _chipW,
          chipH: _chipH,
        ),
      );
    }
    if (kIsWeb) {
      return SizedBox(width: laneWidth, child: _buildWrap(context));
    }
    if (!disableMotion && !Responsive.isDesktop(context)) {
      return _PlatformProofChipsAutoScroll(
        isMobile: isMobile,
        isTablet: isTablet,
        items: _items,
        chipW: _chipW,
        chipH: _chipH,
      );
    }
    return _buildWrap(context);
  }

  Widget _buildWrap(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double chipW = math.min(_chipW, constraints.maxWidth);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.7,
              maxScaleFactor: 1.2,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 8 : 10,
            runSpacing: isMobile ? 8 : 10,
            children: <Widget>[
              for (final e in _items)
                _PlatformTile(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  item: e,
                  chipW: chipW,
                  chipH: _chipH,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Horizontal marquee: duplicated segment + [AnimationController]; chips use
/// the same [\_PlatformTile] (no [FittedBox] column overflow).
class _PlatformProofChipsAutoScroll extends StatefulWidget {
  const _PlatformProofChipsAutoScroll({
    required this.isMobile,
    required this.isTablet,
    required this.items,
    required this.chipW,
    required this.chipH,
  });

  final bool isMobile;
  final bool isTablet;
  final List<({String label, String subtitle, String asset})> items;
  final double chipW;
  final double chipH;

  @override
  State<_PlatformProofChipsAutoScroll> createState() =>
      _PlatformProofChipsAutoScrollState();
}

class _PlatformProofChipsAutoScrollState
    extends State<_PlatformProofChipsAutoScroll>
    with SingleTickerProviderStateMixin {
  static const int _durationMs = 50000;
  AnimationController? _c;

  double get _gap => widget.isMobile ? 8.0 : 10.0;
  int get _n => widget.items.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      if (_c != null) {
        _c!.dispose();
        _c = null;
      }
    } else {
      _c ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null) {
      return _fallbackWrap();
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.7,
          maxScaleFactor: 1.2,
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double chipW = math.min(widget.chipW, c.maxWidth);
          // One loop = full segment; scroll offset equals this after one pass.
          final double loopW = _n * chipW + _n * _gap;
          return ClipRect(
            child: SizedBox(
              width: c.maxWidth,
              height: widget.chipH,
              child: AnimatedBuilder(
                animation: _c!,
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(-_c!.value * loopW, 0),
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 0,
                      maxWidth: double.infinity,
                      child: SizedBox(
                        // The moving marquee track is intentionally wider than
                        // the viewport; ClipRect above limits the visible lane.
                        width: (loopW * 2) - _gap,
                        child: _segmentRow(chipW: chipW, duplicate: true),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackWrap() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double chipW = math.min(widget.chipW, constraints.maxWidth);
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: widget.isMobile ? 8 : 10,
          runSpacing: widget.isMobile ? 8 : 10,
          children: <Widget>[
            for (final e in widget.items)
              _PlatformTile(
                isMobile: widget.isMobile,
                isTablet: widget.isTablet,
                item: e,
                chipW: chipW,
                chipH: widget.chipH,
              ),
          ],
        );
      },
    );
  }

  Widget _segmentRow({required double chipW, bool duplicate = false}) {
    final List<({String label, String subtitle, String asset})> list = duplicate
        ? <({String label, String subtitle, String asset})>[
            ...widget.items,
            ...widget.items,
          ]
        : widget.items;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < list.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: _gap),
          _PlatformTile(
            isMobile: widget.isMobile,
            isTablet: widget.isTablet,
            item: list[i],
            chipW: chipW,
            chipH: widget.chipH,
          ),
        ],
      ],
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.isMobile,
    required this.isTablet,
    required this.item,
    required this.chipW,
    required this.chipH,
  });

  final bool isMobile;
  final bool isTablet;
  final ({String label, String subtitle, String asset}) item;
  final double chipW;
  final double chipH;

  @override
  Widget build(BuildContext context) {
    final double titleSize = isMobile ? 12.5 : (isTablet ? 13.0 : 13.5);
    final double subtitleSize = isMobile ? 9.8 : 10.5;
    final double hPad = isMobile ? 12.0 : 14.0;
    final double vPad = isMobile ? 9.0 : 10.0;
    final double iconS = isMobile ? 42.0 : 46.0;
    final double g = isMobile ? 10.0 : 12.0;
    return Container(
      width: chipW,
      height: chipH,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double innerH2 = c.maxHeight;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox.square(
                dimension: iconS,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.32),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: Image.asset(
                    item.asset,
                    width: iconS - 8,
                    height: iconS - 8,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      size: isMobile ? 20 : 22,
                      color: HomeWarmColors.eyebrowMuted.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
              SizedBox(width: g),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: innerH2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
