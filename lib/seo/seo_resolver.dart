import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/data/content_articles_data.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/seo/seo_metadata.dart';

/// Resolves [SeoMetadata] and canonical path for the current [Uri] (path + query not used for duplicate content).
(SeoMetadata meta, String canonicalPath) resolveSeoForUri(Uri uri) {
  final path = uri.path.isEmpty ? '/' : uri.path;
  final normalized = path.length > 1 && path.endsWith('/') ? path.substring(0, path.length - 1) : path;

  // —— Landing pages (search-intent) ——
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

  // —— Core marketing routes ——
  if (normalized == '/') {
    return (
      const SeoMetadata(
        title: 'Flutter Developer & Product Designer | MVP & Firebase | 4iDeas',
        description:
            'US‑focused Flutter developer and product designer: MVP app development, Flutter + Firebase, '
            'and end‑to‑end delivery from Richmond, VA. iOS, Android, and web from one codebase.',
      ),
      '/',
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
        title: 'Contact — Start a Flutter or MVP Project | 4iDeas',
        description:
            'Tell us about your app idea, timeline, and stack. Flutter + Firebase projects, MVP builds, '
            'and product design engagements for US clients—response with candid next steps.',
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
        final title = '${cs.title} — Case Study | 4iDeas';
        final desc = SeoMetadata.clipDescription(
          '${cs.subtitle} ${cs.overview}'.replaceAll(RegExp(r'\s+'), ' ').trim(),
        );
        return (
          SeoMetadata(title: title, description: desc),
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
    return (const SeoMetadata(title: 'Sign In | 4iDeas', description: 'Sign in to your 4iDeas account.'), '/login');
  }
  if (normalized == '/signup') {
    return (const SeoMetadata(title: 'Create Account | 4iDeas', description: 'Create a 4iDeas account.'), '/signup');
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
