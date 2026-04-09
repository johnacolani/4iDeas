import 'package:flutter/widgets.dart';

import 'design_system_html_platform_stub.dart'
    if (dart.library.io) 'design_system_html_platform_io.dart'
    if (dart.library.html) 'design_system_html_platform_html.dart' as impl;

Widget buildDesignSystemHtmlView({
  required String webRelativePath,
  required String flutterAssetPath,
}) {
  return impl.buildDesignSystemHtmlView(
    webRelativePath: webRelativePath,
    flutterAssetPath: flutterAssetPath,
  );
}
