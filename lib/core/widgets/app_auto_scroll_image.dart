import 'dart:async';

import 'package:flutter/material.dart';

/// Horizontal auto-scrolling strip of [assets/image_0.png] … [assets/image_10.png].
///
/// Repeats tiles so total width always exceeds the viewport (fixes wide screens /
/// web where [ScrollPosition.maxScrollExtent] was 0 and no motion occurred).
/// Starts the scroll timer after the first frame so [ScrollController.hasClients]
/// is reliable on web.
class AppAutoScrollImage extends StatefulWidget {
  const AppAutoScrollImage({super.key});

  /// Number of distinct assets in `assets/image_*.png`.
  static const int kAssetCount = 11;

  @override
  State<AppAutoScrollImage> createState() => _AppAutoScrollImageState();
}

class _AppAutoScrollImageState extends State<AppAutoScrollImage> {
  final ScrollController _scrollController = ScrollController();

  /// Image tiles: baseline (56–80) × this scale. 0.56 ≈ 20% smaller than the previous 0.7 scale.
  static const double _imageSizeScale = 0.56;

  /// Horizontal inset per tile (gap between images = 2 × this).
  static const double _tileHorizontalPadding = 14.0;

  static const Duration _autoScrollDuration = Duration(milliseconds: 900);
  static const Duration _timerInterval = Duration(milliseconds: 1200);

  Timer? _timer;
  bool _scrollingRight = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(_timerInterval, (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final maxExtent = pos.maxScrollExtent;
      if (maxExtent < 8) {
        // Still laying out or not enough overflow — try next tick.
        return;
      }

      final step = _stepPixels(pos.viewportDimension);
      double target;
      if (_scrollingRight) {
        target = pos.pixels + step;
      } else {
        target = pos.pixels - step;
      }

      if (target >= 0 && target <= maxExtent) {
        _scrollController.animateTo(
          target,
          duration: _autoScrollDuration,
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _scrollingRight = !_scrollingRight;
          _startAutoScroll();
        });
      }
    });
  }

  /// Scroll distance per tick — proportional to tile size, capped for smooth motion.
  double _stepPixels(double viewportWidth) {
    final w = _itemWidthForViewport(viewportWidth);
    return (w * 0.85).clamp(18.0, 54.0);
  }

  double _itemWidthForViewport(double viewportWidth) {
    final double base;
    if (viewportWidth < 360) {
      base = 56;
    } else if (viewportWidth < 600) {
      base = 64;
    } else if (viewportWidth < 1200) {
      base = 72;
    } else {
      base = 80;
    }
    return (base * _imageSizeScale).clamp(22.0, 120.0);
  }

  double _stripHeightForItemWidth(double itemWidth) {
    return (itemWidth + 18 * _imageSizeScale).clamp(46.0, 82.0);
  }

  /// Each tile’s laid-out width including horizontal padding (must match item [Padding]).
  double _tileStride(double itemWidth) {
    return itemWidth + _tileHorizontalPadding * 2;
  }

  int _tileCountForWidth(double viewportWidth, double itemWidth) {
    final stride = _tileStride(itemWidth);
    // Enough content to scroll on any screen: viewport + generous overflow.
    final minTotal = viewportWidth * 2.5;
    final n = (minTotal / stride).ceil();
    return n.clamp(24, 120);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final itemWidth = _itemWidthForViewport(maxW);
        final height = _stripHeightForItemWidth(itemWidth);
        final tileCount = _tileCountForWidth(maxW, itemWidth);

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: tileCount,
            itemBuilder: (context, index) {
              final assetIndex = index % AppAutoScrollImage.kAssetCount;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _tileHorizontalPadding,
                  vertical: 4,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/image_$assetIndex.png',
                    width: itemWidth,
                    height: itemWidth,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => SizedBox(
                      width: itemWidth,
                      height: itemWidth,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
