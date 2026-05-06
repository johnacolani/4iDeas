import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildDesignSystemHtmlView({
  required String webRelativePath,
  required String flutterAssetPath,
  required String documentLabel,
}) {
  return _DesignSystemWebView(
    assetPath: flutterAssetPath,
    documentLabel: documentLabel,
  );
}

class _DesignSystemWebView extends StatefulWidget {
  final String assetPath;
  final String documentLabel;

  const _DesignSystemWebView({
    required this.assetPath,
    required this.documentLabel,
  });

  @override
  State<_DesignSystemWebView> createState() => _DesignSystemWebViewState();
}

class _DesignSystemWebViewState extends State<_DesignSystemWebView> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.documentLabel,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
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
