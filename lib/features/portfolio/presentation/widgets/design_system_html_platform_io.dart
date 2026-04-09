import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildDesignSystemHtmlView({
  required String webRelativePath,
  required String flutterAssetPath,
}) {
  return _DesignSystemWebView(assetPath: flutterAssetPath);
}

class _DesignSystemWebView extends StatefulWidget {
  final String assetPath;

  const _DesignSystemWebView({required this.assetPath});

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
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
