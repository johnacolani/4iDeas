// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String _absoluteUrlForWebRelativePath(String webRelativePath) {
  final baseHref =
      html.document.querySelector('base')?.getAttribute('href')?.trim();
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
  required String documentLabel,
}) {
  return _DesignSystemHtmlIframe(
    url: _absoluteUrlForWebRelativePath(webRelativePath),
    assetPath: flutterAssetPath,
    documentLabel: documentLabel,
  );
}

class _DesignSystemHtmlIframe extends StatefulWidget {
  final String url;
  final String assetPath;
  final String documentLabel;

  const _DesignSystemHtmlIframe({
    required this.url,
    required this.assetPath,
    required this.documentLabel,
  });

  @override
  State<_DesignSystemHtmlIframe> createState() =>
      _DesignSystemHtmlIframeState();
}

class _DesignSystemHtmlIframeState extends State<_DesignSystemHtmlIframe> {
  late final String _viewType =
      'design-system-iframe-${identityHashCode(this)}';
  late final html.IFrameElement _iframe;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _iframe = html.IFrameElement()
      ..title = widget.documentLabel
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#ffffff';
    _iframe
      ..setAttribute('aria-label', widget.documentLabel)
      ..setAttribute('tabindex', '0');

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      return _iframe;
    });
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final source = await rootBundle.loadString(widget.assetPath);
      _iframe.setAttribute('srcdoc', _withBaseHref(source, widget.url));
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (error) {
      _iframe.src = widget.url;
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _withBaseHref(String source, String url) {
    final baseTag = '<base href="$url">';
    if (source.contains('<head>')) {
      return source.replaceFirst('<head>', '<head>$baseTag');
    }
    return '$baseTag$source';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.documentLabel,
      child: Stack(
        children: [
          HtmlElementView(viewType: _viewType),
          if (_loading)
            Center(
              child: Semantics(
                label: 'Loading design system document',
                liveRegion: true,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
