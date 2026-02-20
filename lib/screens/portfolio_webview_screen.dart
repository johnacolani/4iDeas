import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional import - only import webview_flutter for mobile platforms
import 'package:webview_flutter/webview_flutter.dart' 
    if (dart.library.html) 'package:four_ideas/screens/portfolio_webview_stub.dart';

class PortfolioWebViewScreen extends StatefulWidget {
  const PortfolioWebViewScreen({super.key});

  @override
  State<PortfolioWebViewScreen> createState() => _PortfolioWebViewScreenState();
}

class _PortfolioWebViewScreenState extends State<PortfolioWebViewScreen> {
  dynamic _controller;
  bool _isLoading = true;
  final String _url = 'https://sites.google.com/view/senior-interaction-product-d/home';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // For web, open URL in in-app web view
      _openUrlInBrowser();
      _isLoading = false;
    } else {
      // For mobile platforms, use WebView
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    if (kIsWeb) return;
    
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (dynamic error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onNavigationRequest: (dynamic request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_url));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openUrlInBrowser() async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      // Try in-app web view first, fallback to external if not supported
      try {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildWebView() {
    // For web, use url_launcher to open in new tab with in-app web view
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff020923),
            Color(0xff051136),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.launch,
              size: 80,
              color: ColorManager.orange,
            ),
            const SizedBox(height: 32),
            Text(
              'Opening Portfolio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your portfolio is opening in a new tab.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                _openUrlInBrowser();
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                'Open Portfolio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    
    if (kIsWeb) {
      // For web, open in browser (iframe blocked by Google Sites)
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.amber[100],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff020923),
          title: Text(
            'Portfolio',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 20 : 22,
            ),
          ),
        ),
        body: _buildWebView(),
      );
    }
    
    // For mobile platforms - use WebView
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Portfolio',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
          ),
        ),
        actions: [
          if (_controller != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                try {
                  (_controller as dynamic).reload();
                } catch (e) {
                  // Handle error
                }
              },
            ),
        ],
      ),
      body: _controller != null
          ? Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: const Color(0xff020923),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(ColorManager.orange),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading portfolio...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 16 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ColorManager.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Failed to load WebView',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.orange,
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
