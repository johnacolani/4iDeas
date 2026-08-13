import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Portfolio image that decodes local assets close to their rendered size and
/// renders uploaded network images in a web-friendly way.
///
/// This reduces peak memory and frame jank from decoding oversized assets.
class AdaptiveAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AdaptiveAssetImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (_isNetworkPath(assetPath)) {
      return Image.network(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        webHtmlElementStrategy: kIsWeb
            ? WebHtmlElementStrategy.prefer
            : WebHtmlElementStrategy.never,
        errorBuilder: errorBuilder,
      );
    }

    // Web decoders are more sensitive to resize hints and can throw noisy
    // layout/assert loops in some browsers. Keep web on default decoding path.
    final int? cacheWidthPx;
    final int? cacheHeightPx;
    if (kIsWeb) {
      cacheWidthPx = null;
      cacheHeightPx = null;
    } else {
      final double dpr = MediaQuery.devicePixelRatioOf(context);
      cacheWidthPx = _logicalToCachePx(width, dpr);
      cacheHeightPx = _logicalToCachePx(height, dpr);
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: gaplessPlayback,
      filterQuality: filterQuality,
      cacheWidth: cacheWidthPx,
      cacheHeight: cacheHeightPx,
      errorBuilder: errorBuilder,
    );
  }

  bool _isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  int? _logicalToCachePx(double? logicalSize, double dpr) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final int px = (logicalSize * dpr).round();
    return math.max(1, px);
  }
}
