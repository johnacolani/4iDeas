import 'package:flutter/material.dart';

Widget buildDesignSystemHtmlView({
  required String webRelativePath,
  required String flutterAssetPath,
  required String documentLabel,
}) {
  return Center(
    child: Semantics(
      liveRegion: true,
      child: const Text(
        'Design system document is not available on this platform.',
      ),
    ),
  );
}
