// Stub file for web platform to avoid importing webview_flutter
// This file provides stub types for web compilation

import 'package:flutter/widgets.dart';

// Stub classes that won't be used on web
class WebViewController {
  void setJavaScriptMode(dynamic mode) {}
  void setBackgroundColor(dynamic color) {}
  void setNavigationDelegate(dynamic delegate) {}
  void loadRequest(Uri uri) {}
  void reload() {}
}

class JavaScriptMode {
  static const unrestricted = null;
}

class NavigationDelegate {
  NavigationDelegate({
    required this.onPageStarted,
    required this.onPageFinished,
    required this.onWebResourceError,
    required this.onNavigationRequest,
  });
  
  final Function(String) onPageStarted;
  final Function(String) onPageFinished;
  final Function(dynamic) onWebResourceError;
  final Function(dynamic) onNavigationRequest;
}

class NavigationDecision {
  static const navigate = null;
}

class NavigationRequest {
  final String url;
  NavigationRequest({required this.url});
}

class WebResourceError {
  final String description;
  WebResourceError({required this.description});
}

class WebViewWidget extends StatelessWidget {
  const WebViewWidget({required this.controller, super.key});
  final dynamic controller;
  
  @override
  Widget build(BuildContext context) {
    // This should never be called on web since we check kIsWeb first
    return const SizedBox.shrink();
  }
}
