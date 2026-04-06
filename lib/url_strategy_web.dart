import 'package:flutter_web_plugins/url_strategy.dart';

/// Use path-based URLs (`/portfolio/...`) so the address bar matches [GoRouter], not only `#/portfolio`.
void configureWebUrlStrategy() {
  usePathUrlStrategy();
}
