import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:four_ideas/screens/home_screen.dart';
import 'package:four_ideas/screens/portfolio_screen.dart';
import 'package:four_ideas/screens/services_screen.dart';
import 'package:four_ideas/screens/about_us_screen.dart';
import 'package:four_ideas/screens/order_here_screen.dart';

/// App route paths. Use these when calling context.go() or context.push().
abstract class AppRoutes {
  static const String home = '/';
  static const String portfolio = '/portfolio';
  static const String services = '/services';
  static const String about = '/about';
  static const String orderHere = '/order-here';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.portfolio,
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderHere,
        builder: (context, state) => const OrderHereScreen(),
      ),
    ],
  );
}
