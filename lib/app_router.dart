import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:four_ideas/screens/home_screen.dart';
import 'package:four_ideas/screens/portfolio_screen.dart';
import 'package:four_ideas/screens/services_screen.dart';
import 'package:four_ideas/screens/about_us_screen.dart';
import 'package:four_ideas/screens/order_here_screen.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/screens/case_study_detail_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/login_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/signup_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:four_ideas/features/auth/presentation/screens/profile_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_order_detail_screen.dart';
import 'package:four_ideas/features/payment/presentation/screens/payment_screen.dart';
import 'package:four_ideas/features/contract/presentation/screens/contract_view_screen.dart';
import 'package:four_ideas/features/portfolio/presentation/screens/design_philosophy_screen.dart';

/// App route paths. Use these when calling context.go() or context.push().
/// Design: all screen navigation goes through GoRouter for consistency and deep linking.
abstract class AppRoutes {
  static const String home = '/';
  static const String portfolio = '/portfolio';
  static const String portfolioCaseStudy = '/portfolio/case-study';
  static String portfolioCaseStudyPath(String id) => '$portfolioCaseStudy/$id';
  static const String designPhilosophy = '/portfolio/design-philosophy';

  static const String services = '/services';
  static const String about = '/about';
  static const String orderHere = '/order-here';

  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String profile = '/profile';

  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/detail';
  static const String payment = '/payment';
  static const String contractView = '/contract-view';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // Portfolio sub-routes are top-level so hash / path URL updates reliably on web.
      GoRoute(
        path: AppRoutes.designPhilosophy,
        builder: (context, state) => const DesignPhilosophyScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.portfolioCaseStudy}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final found = PortfolioData.caseStudies.where((c) => c.id == id).toList();
          if (found.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text('Case study not found'),
              ),
            );
          }
          return CaseStudyDetailScreen(caseStudy: found.first.withAdaptiveBeforeDesignSystem());
        },
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
      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ??
              (state.extra is String ? state.extra as String : null) ??
              '';
          return EmailVerificationScreen(userEmail: email);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // Admin
      GoRoute(
        path: AppRoutes.adminOrders,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOrderDetail,
        builder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final order = extra?['order'] as Map<String, dynamic>?;
          final onResponseAdded = extra?['onResponseAdded'] as VoidCallback?;
          if (order == null) {
            return Scaffold(
              body: Center(child: Text('Order not found')),
            );
          }
          return AdminOrderDetailScreen(
            order: order,
            onResponseAdded: onResponseAdded ?? () {},
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final order = extra?['order'] as Map<String, dynamic>?;
          final onSuccess = extra?['onSuccess'] as VoidCallback?;
          if (order == null) {
            return Scaffold(
              body: Center(child: Text('Order not found')),
            );
          }
          return PaymentScreen(order: order, onPaymentSuccess: onSuccess);
        },
      ),
      GoRoute(
        path: AppRoutes.contractView,
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>?;
          if (order == null) {
            return Scaffold(
              body: Center(child: Text('Order not found')),
            );
          }
          return ContractViewScreen(order: order);
        },
      ),
    ],
  );
}
