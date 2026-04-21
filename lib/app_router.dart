import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:four_ideas/screens/home_screen.dart';
import 'package:four_ideas/screens/portfolio_screen.dart';
import 'package:four_ideas/screens/services_screen.dart';
import 'package:four_ideas/screens/about_us_screen.dart';
import 'package:four_ideas/screens/order_here_screen.dart';
import 'package:four_ideas/screens/contact_us_screen.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/data/content_articles_data.dart';
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
import 'package:four_ideas/features/portfolio/presentation/screens/case_study_design_system_screen.dart';
import 'package:four_ideas/screens/insight_article_screen.dart';
import 'package:four_ideas/screens/insights_screen.dart';
import 'package:four_ideas/screens/local_richmond_landing_screen.dart';
import 'package:four_ideas/screens/seo_topic_landing_screen.dart';

/// App route paths. Use these when calling context.go() or context.push().
/// Design: all screen navigation goes through GoRouter for consistency and deep linking.
abstract class AppRoutes {
  static const String home = '/';
  static const String portfolio = '/portfolio';
  static const String portfolioCaseStudy = '/portfolio/case-study';
  static String portfolioCaseStudyPath(String id) => '$portfolioCaseStudy/$id';
  static String portfolioCaseStudyDesignSystemPath(String id) =>
      '$portfolioCaseStudy/$id/design-system';
  static String portfolioDesignSystemPath(String id) =>
      '$portfolio/design-system/$id';
  static const String designPhilosophy = '/portfolio/design-philosophy';

  static const String services = '/services';
  static const String about = '/about';
  static const String orderHere = '/order-here';
  /// Full-page contact (matches drawer + deep link); same content as the legacy modal.
  static const String contact = '/contact';
  static const String insights = '/insights';
  static String insightsArticlePath(String slug) => '$insights/$slug';

  /// SEO / search-intent landing pages (also listed in `web/sitemap.xml`).
  static const String flutterDeveloperRichmondVa = '/flutter-developer-richmond-va';
  static const String mvpAppDevelopment = '/mvp-app-development';
  static const String productDesignFlutterEngineering = '/product-design-flutter-engineering';

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
        path: '${AppRoutes.portfolio}/design-system/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (!PortfolioData.caseStudyHasDesignSystemDoc(id)) {
            return Scaffold(
              body: Center(
                child: Text('Design system not found'),
              ),
            );
          }
          return CaseStudyDesignSystemScreen(designSystemId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.portfolioCaseStudy}/:id/design-system',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (!PortfolioData.caseStudyHasDesignSystemDoc(id)) {
            return Scaffold(
              body: Center(
                child: Text('Design system not found'),
              ),
            );
          }
          return CaseStudyDesignSystemScreen(designSystemId: id);
        },
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
      GoRoute(
        path: AppRoutes.contact,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.insights}/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final article = ContentArticlesData.bySlug(slug);
          if (article == null) {
            return const Scaffold(
              body: Center(
                child: Text('Article not found'),
              ),
            );
          }
          return InsightArticleScreen(article: article);
        },
      ),
      GoRoute(
        path: AppRoutes.flutterDeveloperRichmondVa,
        builder: (context, state) => const LocalRichmondLandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.mvpAppDevelopment,
        builder: (context, state) => const SeoTopicLandingScreen(
          topic: SeoLandingTopic.mvpAppDevelopment,
        ),
      ),
      GoRoute(
        path: AppRoutes.productDesignFlutterEngineering,
        builder: (context, state) => const SeoTopicLandingScreen(
          topic: SeoLandingTopic.productDesignFlutterEngineering,
        ),
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
