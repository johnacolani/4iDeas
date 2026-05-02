import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/data/content_articles_data.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/seo/seo_metadata.dart';

/// Resolves [SeoMetadata] and canonical path for the current [Uri] (path + query not used for duplicate content).
(SeoMetadata meta, String canonicalPath) resolveSeoForUri(Uri uri) {
  final path = uri.path.isEmpty ? '/' : uri.path;
  final normalized = path.length > 1 && path.endsWith('/') ? path.substring(0, path.length - 1) : path;

  // —— Landing pages (search-intent) ——
  if (normalized == AppRoutes.flutterDeveloperVirginia) {
    return (
      const SeoMetadata(
        title: 'Flutter Developer in Virginia | MVP, Product Design, Firebase | 4iDeas',
        description:
            'Virginia-based Flutter developer for startups and businesses: product design, MVP app development, '
            'Firebase integration, and accountable delivery across iOS, Android, and web.',
      ),
      AppRoutes.flutterDeveloperVirginia,
    );
  }
  if (normalized == AppRoutes.flutterDeveloperRichmondVa) {
    return (
      const SeoMetadata(
        title: 'Flutter Developer in Richmond, VA | Virginia & US App Help | 4iDeas',
        description:
            'Richmond‑based Flutter developer and product designer for Virginia businesses and US teams: '
            'MVP builds, Flutter + Firebase, iOS, Android, and web—clear scope and one accountable delivery path.',
      ),
      AppRoutes.flutterDeveloperRichmondVa,
    );
  }
  if (normalized == AppRoutes.mvpAppDevelopment) {
    return (
      const SeoMetadata(
        title: 'MVP App Development with Flutter & Firebase | 4iDeas',
        description:
            'Ship a credible MVP faster: scoped Flutter development, Firebase backends, UX that matches your market, '
            'and clear communication for US teams—design and engineering from one place.',
      ),
      AppRoutes.mvpAppDevelopment,
    );
  }
  if (normalized == AppRoutes.productDesignFlutterEngineering) {
    return (
      const SeoMetadata(
        title: 'Product Design + Flutter Engineering | Designer‑Developer | 4iDeas',
        description:
            'Hire a product designer who ships in Flutter: UX/UI, design systems, Firebase integration, '
            'and production code for iOS, Android, and web—aligned with US client expectations.',
      ),
      AppRoutes.productDesignFlutterEngineering,
    );
  }
  if (normalized == AppRoutes.firebaseAppDevelopmentServices) {
    return (
      const SeoMetadata(
        title: 'Firebase App Development Services | Flutter + Firebase Experts | 4iDeas',
        description:
            'Firebase app development services for production products: Auth, Firestore, Cloud Functions, Hosting, '
            'and analytics for Flutter-based MVPs and business apps.',
      ),
      AppRoutes.firebaseAppDevelopmentServices,
    );
  }

  // —— Core marketing routes ——
  if (normalized == '/') {
    return (
      const SeoMetadata(
        title: 'Flutter App Developer for iOS, Android & Web | 4iDeas',
        description:
            'I design and build production-ready Flutter apps, Firebase backends, AI features, dashboards, and MVPs for startups and businesses.',
      ),
      '/',
    );
  }
  if (normalized == AppRoutes.flutterAppDevelopment) {
    return (
      const SeoMetadata(
        title: 'Flutter App Development Services | iOS, Android & Web | 4iDeas',
        description:
            'Hire a Flutter developer to design and build cross-platform apps for iOS, Android, and Web using Flutter, Firebase, and production-ready architecture.',
      ),
      AppRoutes.flutterAppDevelopment,
    );
  }
  if (normalized == AppRoutes.flutterMvpDevelopment) {
    return (
      const SeoMetadata(
        title: 'Flutter MVP Development for Startups | 4iDeas',
        description:
            'Build and launch your startup MVP with Flutter, Firebase, product design, and cross-platform development for iOS, Android, and Web.',
      ),
      AppRoutes.flutterMvpDevelopment,
    );
  }
  if (normalized == AppRoutes.firebaseAppDevelopment) {
    return (
      const SeoMetadata(
        title: 'Firebase App Development for Flutter Apps | 4iDeas',
        description:
            'Firebase development for Flutter apps, including authentication, Firestore, Cloud Functions, push notifications, real-time data, and analytics.',
      ),
      AppRoutes.firebaseAppDevelopment,
    );
  }
  if (normalized == AppRoutes.productDesignUxMobileApps) {
    return (
      const SeoMetadata(
        title: 'Product Design and UX for Mobile Apps | 4iDeas',
        description:
            'Product design, UX flows, UI systems, and mobile app design for startups and businesses building real digital products.',
      ),
      AppRoutes.productDesignUxMobileApps,
    );
  }
  if (normalized == AppRoutes.aiChatbotAdminDashboardDevelopment) {
    return (
      const SeoMetadata(
        title: 'AI Chatbot and Admin Dashboard Development | 4iDeas',
        description:
            'Design and build AI-assisted chat features, admin dashboards, business workflow tools, and role-based management systems.',
      ),
      AppRoutes.aiChatbotAdminDashboardDevelopment,
    );
  }
  if (normalized == AppRoutes.flutterWebAppDevelopment) {
    return (
      const SeoMetadata(
        title: 'Flutter Web App Development | 4iDeas',
        description:
            'Build responsive Flutter web apps and cross-platform digital products with clean UI, Firebase integration, and scalable architecture.',
      ),
      AppRoutes.flutterWebAppDevelopment,
    );
  }
  if (normalized == AppRoutes.caseStudies) {
    return (
      const SeoMetadata(
        title: 'Flutter and Product Design Case Studies | 4iDeas',
        description:
            'Explore 4iDeas case studies across Flutter apps, Firebase platforms, product design, AI assistants, dashboards, and cross-platform development.',
      ),
      AppRoutes.caseStudies,
    );
  }
  if (normalized == '/portfolio') {
    return (
      const SeoMetadata(
        title: 'Portfolio — Flutter Apps, Case Studies & Product Design | 4iDeas',
        description:
            'Case studies and shipped Flutter products: business constraints, role, outcomes, and links to live apps. '
            'See product design plus engineering proof—not a screenshot gallery.',
      ),
      '/portfolio',
    );
  }
  if (normalized == '/services') {
    return (
      const SeoMetadata(
        title: 'Services — Flutter, MVP, Firebase & Product Design | 4iDeas',
        description:
            'Hire for MVP delivery, Flutter development, Firebase backends, product UX/UI, and AI features that belong '
            'in the product. Clear scopes for startups and established US businesses.',
      ),
      '/services',
    );
  }
  if (normalized == '/about') {
    return (
      const SeoMetadata(
        title: 'About — Flutter Engineer & Product Designer | 4iDeas',
        description:
            'Background and how I work with US clients: Flutter engineering, product design, Firebase, '
            'and accountable delivery—Richmond, VA roots with nationwide reach.',
      ),
      '/about',
    );
  }
  if (normalized == '/contact') {
    return (
      const SeoMetadata(
        title: 'Start a Flutter App Project | Contact 4iDeas',
        description:
            'Contact 4iDeas to discuss your Flutter app, MVP, Firebase backend, AI feature, dashboard, or product design project.',
      ),
      '/contact',
    );
  }
  if (normalized == '/order-here') {
    return (
      const SeoMetadata(
        title: 'Order & Engage — 4iDeas',
        description:
            'Start an engagement with 4iDeas: scope, options, and next steps for Flutter development and product design.',
      ),
      '/order-here',
    );
  }
  if (normalized == AppRoutes.insights) {
    return (
      const SeoMetadata(
        title: 'Insights — Flutter, MVP, Product Design, Firebase, AI | 4iDeas',
        description:
            'Actionable articles for founders and product teams: Flutter development, MVP planning, '
            'product design, Firebase architecture, and AI-assisted app features.',
      ),
      AppRoutes.insights,
    );
  }

  if (normalized.startsWith('${AppRoutes.insights}/')) {
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2) {
      final slug = segments[1];
      final article = ContentArticlesData.bySlug(slug);
      if (article != null) {
        return (
          SeoMetadata(
            title: '${article.title} | 4iDeas Insights',
            description: SeoMetadata.clipDescription(article.excerpt),
          ),
          AppRoutes.insightsArticlePath(slug),
        );
      }
    }
  }

  // —— Portfolio: case study detail ——
  if (normalized.startsWith('/portfolio/case-study/')) {
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    // portfolio, case-study, id, ...
    if (segments.length >= 3) {
      final id = segments[2];
      final match = PortfolioData.caseStudies.where((c) => c.id == id);
      final cs = match.isEmpty ? null : match.first;
      if (cs != null) {
        final defaultTitle = '${cs.title} — Case Study | 4iDeas';
        final defaultDesc = SeoMetadata.clipDescription(
          '${cs.subtitle} ${cs.overview}'.replaceAll(RegExp(r'\s+'), ' ').trim(),
        );
        final perCaseMeta = <String, SeoMetadata>{
          'asd': const SeoMetadata(
            title: 'Absolute Stone Design Case Study | Flutter + Firebase Operations Platform | 4iDeas',
            description:
                'Enterprise Flutter + Firebase case study: multi-role operations platform for admin, sales, scheduler, installer, and client workflows with governed AI and adaptive cross-platform UX.',
          ),
          'service-flow': const SeoMetadata(
            title: 'Service Flow Case Study | Multi-tenant SaaS UX + Flutter Product System | 4iDeas',
            description:
                'Multi-tenant SaaS case study for field service operations: role-based workflows, tenant-safe UX, design system strategy, and product decisions for scalable Flutter delivery.',
          ),
          'twin-scriptures': const SeoMetadata(
            title: 'Twin Scriptures Case Study | Personalized Spiritual App UX | Flutter | 4iDeas',
            description:
                'Consumer Flutter app case study covering bilingual scripture reading, RTL UX, visual personalization onboarding, and product design decisions that improved completion and engagement.',
          ),
          'rose-chat-seasonal-campaign-engine': const SeoMetadata(
            title: 'Rose AI Seasonal and Holiday Celebration Campaign Case Study | Conversational AI Product Design | 4iDeas',
            description:
                'AI product design case study: backend-driven seasonal campaign system with safe rollout controls, dynamic conversational UX, preview modes, and governed operations.',
          ),
        };
        final meta = perCaseMeta[id] ?? SeoMetadata(title: defaultTitle, description: defaultDesc);
        return (
          meta,
          '/portfolio/case-study/$id',
        );
      }
    }
  }

  if (normalized.startsWith('/portfolio/design-system/')) {
    return (
      const SeoMetadata(
        title: 'Design System — Flutter & Product UI | 4iDeas Portfolio',
        description:
            'Design system documentation and Flutter implementation examples from shipped work—tokens, components, '
            'and patterns for consistent product UI.',
      ),
      normalized,
    );
  }

  if (normalized == '/portfolio/design-philosophy') {
    return (
      const SeoMetadata(
        title: 'Design Philosophy — Product Thinking | 4iDeas',
        description:
            'Principles behind product design and Flutter execution: clarity, accountability, and buildable specifications.',
      ),
      '/portfolio/design-philosophy',
    );
  }

  // Auth and admin: noindex-friendly titles (still predictable in tabs).
  if (normalized == '/login') {
    return (
      const SeoMetadata(
        title: 'Sign In | 4iDeas',
        description: 'Sign in to your 4iDeas account.',
        robots: 'noindex, nofollow',
      ),
      '/login',
    );
  }
  if (normalized == '/signup') {
    return (
      const SeoMetadata(
        title: 'Create Account | 4iDeas',
        description: 'Create a 4iDeas account.',
        robots: 'noindex, nofollow',
      ),
      '/signup',
    );
  }
  if (normalized == '/forgot-password' || normalized == '/email-verification' || normalized == '/profile') {
    return (
      const SeoMetadata(
        title: 'Account | 4iDeas',
        description: 'Account access and verification.',
        robots: 'noindex, nofollow',
      ),
      normalized,
    );
  }
  if (normalized.startsWith('/admin') || normalized == '/payment' || normalized == '/contract-view') {
    return (
      const SeoMetadata(
        title: 'Restricted Area | 4iDeas',
        description: 'Restricted application area.',
        robots: 'noindex, nofollow',
      ),
      normalized,
    );
  }

  return (
    const SeoMetadata(
      title: '4iDeas — Flutter App Development & Product Design',
      description:
          'Flutter development, product design, MVP delivery, and Firebase for US clients. Based in Richmond, VA.',
    ),
    normalized == '/' ? '/' : normalized,
  );
}
