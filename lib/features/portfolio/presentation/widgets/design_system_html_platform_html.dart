// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

String _absoluteUrlForWebRelativePath(String webRelativePath) {
  final baseHref = html.document.querySelector('base')?.getAttribute('href')?.trim();
  if (baseHref != null &&
      (baseHref.startsWith('http://') || baseHref.startsWith('https://'))) {
    return Uri.parse(baseHref).resolve(webRelativePath).toString();
  }
  final origin = html.window.location.origin;
  final pathOnly = baseHref ?? '/';
  final normalized = pathOnly.endsWith('/') ? pathOnly : '$pathOnly/';
  return Uri.parse('$origin$normalized').resolve(webRelativePath).toString();
}

Widget buildDesignSystemHtmlView({
  required String webRelativePath,
  required String flutterAssetPath,
}) {
  return _DesignSystemHtmlIframe(url: _absoluteUrlForWebRelativePath(webRelativePath));
}

class _DesignSystemHtmlIframe extends StatefulWidget {
  final String url;

  const _DesignSystemHtmlIframe({required this.url});

  @override
  State<_DesignSystemHtmlIframe> createState() => _DesignSystemHtmlIframeState();
}

class _DesignSystemHtmlIframeState extends State<_DesignSystemHtmlIframe> {
  late final String _viewType = 'design-system-iframe-${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
