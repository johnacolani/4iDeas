import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helper/app_background.dart';
import '../core/design_system/responsive.dart';
import '../core/design_system/theme.dart';

const LinearGradient _kNavIconGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[
    AppColors.primaryGold,
    AppColors.primaryGoldDark,
  ],
);

/// Reusable 7 entries: hamburger menu and desktop [TabBar].
class _KNav {
  _KNav._();
  static final List<({String label, String route, IconData icon})> items =
      <({String label, String route, IconData icon})>[
    (
      label: 'Home',
      route: AppRoutes.home,
      icon: Icons.home_rounded,
    ),
    (
      label: 'Services',
      route: AppRoutes.services,
      icon: Icons.layers_outlined,
    ),
    (
      label: 'Work',
      route: AppRoutes.portfolio,
      icon: Icons.cases_outlined,
    ),
    (
      label: 'Process',
      route: AppRoutes.designPhilosophy,
      icon: Icons.account_tree_outlined,
    ),
    (
      label: 'About',
      route: AppRoutes.about,
      icon: Icons.info_outlined,
    ),
    (
      label: 'Contact Us',
      route: AppRoutes.contact,
      icon: Icons.mail_outlined,
    ),
    (
      label: 'Blog',
      route: AppRoutes.insights,
      icon: Icons.article_outlined,
    ),
  ];
}

class _NavRoutePreview {
  const _NavRoutePreview({
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;
}

_NavRoutePreview _previewForRoute(String route) {
  switch (route) {
    case AppRoutes.home:
      return const _NavRoutePreview(
        title: 'Home',
        subtitle:
            'Service positioning, proof, and clear next steps for a Flutter engagement.',
        bullets: [
          'What we build: MVPs, dashboards, AI-assisted workflows, cross-platform delivery',
          'Trust: shipped products, case studies, and a transparent process',
          'CTA: start a project and move from idea to a scoped plan',
        ],
      );
    case AppRoutes.services:
      return const _NavRoutePreview(
        title: 'Services',
        subtitle:
            'Scope-friendly offerings across design, Flutter engineering, and Firebase delivery.',
        bullets: [
          'MVP and production builds, role-based business apps, portals',
          'Product UX/UI + implementation that stays aligned',
        ],
      );
    case AppRoutes.portfolio:
      return const _NavRoutePreview(
        title: 'Work',
        subtitle:
            'Interactive portfolio: shipped apps, deep case studies, and real constraints.',
        bullets: [
          'Case studies: problem, solution, outcomes, stack',
          'Platform proof: iOS, Android, Web, Firebase',
        ],
      );
    case AppRoutes.designPhilosophy:
      return const _NavRoutePreview(
        title: 'Process',
        subtitle:
            'The thinking behind delivery: clarity, tradeoffs, and buildable decisions.',
        bullets: [
          'What “good” looks like before code decisions harden',
          'How we communicate scope, risk, and iteration',
        ],
      );
    case AppRoutes.about:
      return const _NavRoutePreview(
        title: 'About',
        subtitle: 'Background, values, and how we collaborate with US teams.',
        bullets: [
          'Senior product + Flutter ownership in one path',
        ],
      );
    case AppRoutes.contact:
      return const _NavRoutePreview(
        title: 'Contact',
        subtitle:
            'Tell us what you want to build—timeline, budget, and success criteria.',
        bullets: [
          'Project intake form (email capture via existing endpoint)',
          'Optional intro call (if configured)',
        ],
      );
    case AppRoutes.insights:
      return const _NavRoutePreview(
        title: 'Blog / Insights',
        subtitle:
            'Practical articles: Flutter, MVPs, Firebase, and AI in real products.',
        bullets: [
          'Founder-friendly explanations with actionable framing',
        ],
      );
    default:
      return const _NavRoutePreview(
        title: 'Page preview',
        subtitle: 'A quick description of this destination in the 4iDeas site.',
        bullets: [
          'Open the page to see full content',
        ],
      );
  }
}

class _NavHoverPreviewCard extends StatelessWidget {
  const _NavHoverPreviewCard({
    required this.route,
    required this.isMobile,
    required this.onOpen,
  });

  final String route;
  final bool isMobile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = _previewForRoute(route);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: isMobile ? double.infinity : 360,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.title,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.subtitle,
                style: GoogleFonts.roboto(
                  color: const Color(0xFFD1D5DB),
                  fontSize: isMobile ? 13.5 : 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              for (final b in p.bullets) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFFF5B32F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onOpen,
                  child: Text(
                    'Open',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF5B32F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavGoldIcon extends StatelessWidget {
  const _NavGoldIcon(this.icon, {this.size = 20});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect b) => _kNavIconGoldGradient.createShader(b),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _hoveredRoute;
  int? _hoveredTabIndex;
  Timer? _hideTimer;
  late final List<LayerLink> _navTabLayerLinks;

  bool get _navHoverPreviewsEnabled => kIsWeb;

  @override
  void initState() {
    super.initState();
    _navTabLayerLinks = List<LayerLink>.generate(
      _KNav.items.length,
      (_) => LayerLink(),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _queueHideIfStillHovering(String route) {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      if (_hoveredRoute != route) return;
      setState(() {
        _hoveredRoute = null;
        _hoveredTabIndex = null;
      });
    });
  }

  void _queueHidePreview() {
    final route = _hoveredRoute;
    if (route == null) return;
    _queueHideIfStillHovering(route);
  }

  void _onNavTabHoverStart(String route, int tabIndex) {
    if (!_navHoverPreviewsEnabled) return;
    _cancelHideTimer();
    if (_hoveredRoute == route && _hoveredTabIndex == tabIndex) return;
    setState(() {
      _hoveredRoute = route;
      _hoveredTabIndex = tabIndex;
    });
  }

  void _onNavTabHoverEnd(String route) {
    if (!_navHoverPreviewsEnabled) return;
    _queueHideIfStillHovering(route);
  }

  void _onPreviewPointerEnter() {
    if (!_navHoverPreviewsEnabled) return;
    _cancelHideTimer();
  }

  void _onPreviewPointerExit() {
    if (!_navHoverPreviewsEnabled) return;
    _queueHidePreview();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final bool showNavHoverPreview = _navHoverPreviewsEnabled && !isMobile;
    final String? previewRoute = showNavHoverPreview ? _hoveredRoute : null;
    final int? previewTabIndex = showNavHoverPreview ? _hoveredTabIndex : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const AppBackground(),
          Positioned.fill(
            child: Column(
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModernTopAppBar(
                        isMobile: isMobile,
                        navTabLayerLinks: _navTabLayerLinks,
                        tabHoverIndicatorIndex:
                            showNavHoverPreview ? _hoveredTabIndex : null,
                        onNavTabHover:
                            showNavHoverPreview ? _onNavTabHoverStart : null,
                        onNavTabHoverEnd:
                            showNavHoverPreview ? _onNavTabHoverEnd : null,
                      ),
                      SizedBox(height: isMobile ? 0 : 6),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Same home content on phone, tablet, and desktop (see [WebScreen]).
                        const WebScreen(),
                        if (previewRoute != null &&
                            previewTabIndex != null) ...[
                          CompositedTransformFollower(
                            link: _navTabLayerLinks[previewTabIndex],
                            showWhenUnlinked: false,
                            targetAnchor: Alignment.bottomCenter,
                            followerAnchor: Alignment.topCenter,
                            offset: const Offset(0, 28),
                            child: MouseRegion(
                              onEnter: (_) => _onPreviewPointerEnter(),
                              onExit: (_) => _onPreviewPointerExit(),
                              child: _NavHoverPreviewCard(
                                route: previewRoute,
                                isMobile: false,
                                onOpen: () {
                                  _cancelHideTimer();
                                  setState(() {
                                    _hoveredRoute = null;
                                    _hoveredTabIndex = null;
                                  });
                                  context.go(previewRoute);
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTopAppBar extends StatelessWidget {
  const _ModernTopAppBar({
    required this.isMobile,
    required this.navTabLayerLinks,
    this.tabHoverIndicatorIndex,
    this.onNavTabHover,
    this.onNavTabHoverEnd,
  });

  final bool isMobile;
  final List<LayerLink> navTabLayerLinks;
  final int? tabHoverIndicatorIndex;
  final void Function(String route, int tabIndex)? onNavTabHover;
  final void Function(String route)? onNavTabHoverEnd;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final topInset = MediaQuery.paddingOf(context).top;
    final double viewportWidth = MediaQuery.sizeOf(context).width;
    // Vertical space for logo / tabs / account; mobile = logo + menu column.
    const double baseBarContentHeight = 90;
    // Web / tablet: taller bar for nav + logo (was 78).
    const double baseBarContentHeightDesktop = 96;
    // Space below the app bar row (logo, nav, account) before the border ends.
    const double bottomContentPadding = 6.0;
    // Inset below the status bar; kept small to keep the bar short.
    const double contentTopNudge = 4.0;
    final double contentHeight =
        isMobile ? baseBarContentHeight : baseBarContentHeightDesktop;
    final navStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        );
    return Padding(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: contentHeight +
                topInset +
                bottomContentPadding +
                contentTopNudge,
            // Horizontal insets: web/tablet left matches [WebScreen] home column gutter.
            padding: EdgeInsets.only(
              left: isMobile ? 6.0 : AppBreakpoints.homeContentGutter,
              // Extra 3% viewport to the right of sign-in / sign-up and founder chip.
              right: (isMobile ? 6.0 : 24.0) + viewportWidth * 0.03,
              top: topInset + contentTopNudge,
              bottom: bottomContentPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isMobile)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryGold,
                                      AppColors.primaryGoldDark,
                                    ],
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset('assets/images/logo.png',
                                      width: 44, height: 44),
                                ),
                              ),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: '4i',
                                      style: TextStyle(
                                        foreground: Paint()
                                          ..shader = const LinearGradient(
                                            colors: [
                                              Color(0xFFF5B32F),
                                              Color(0xFFD89A1C),
                                            ],
                                          ).createShader(
                                            const Rect.fromLTWH(0, 0, 56, 24),
                                          ),
                                      ),
                                    ),
                                    const TextSpan(text: 'Deas'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _AppBarHamburgerButton(),
                        ],
                      )
                    else
                      Padding(
                        // Extra 3% of viewport to the right of the content gutter.
                        padding: EdgeInsets.only(left: viewportWidth * 0.03),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryGold,
                                    AppColors.primaryGoldDark,
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset('assets/images/logo.png',
                                    width: 52, height: 52),
                              ),
                            ),
                            const SizedBox(width: 10),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                children: [
                                  TextSpan(
                                    text: '4i',
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [
                                            Color(0xFFF5B32F),
                                            Color(0xFFD89A1C),
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 56, 24),
                                        ),
                                    ),
                                  ),
                                  const TextSpan(text: 'Deas'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!isMobile) ...[
                      const Spacer(),
                      Expanded(
                        child: _TopNavTabs(
                          currentPath: currentPath,
                          style: navStyle,
                          tabLayerLinks: navTabLayerLinks,
                          tabHoverIndicatorIndex: tabHoverIndicatorIndex,
                          onNavTabHover: onNavTabHover,
                          onNavTabHoverEnd: onNavTabHoverEnd,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const _AccountMetaBlock(mobile: false),
                    ] else ...[
                      const Spacer(),
                      const _AccountMetaBlock(mobile: true),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile app bar: menu below the logo in a [Column] (leading, LTR).
class _AppBarHamburgerButton extends StatelessWidget {
  const _AppBarHamburgerButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        color: const Color(0xFF111827),
        constraints: const BoxConstraints(minWidth: 240),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        padding: EdgeInsets.zero,
        tooltip: 'Menu',
        onSelected: (route) => context.go(route),
        itemBuilder: (context) {
          final entries = _KNav.items.asMap().entries;
          return [
            for (final entry in entries) ...[
              PopupMenuItem<String>(
                value: entry.value.route,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.value.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _NavGoldIcon(entry.value.icon, size: 22),
                  ],
                ),
              ),
              if (entry.key < _KNav.items.length - 1)
                const PopupMenuItem<String>(
                  enabled: false,
                  height: 10,
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x4DFFFFFF),
                  ),
                ),
            ],
          ];
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Icon(
            Icons.menu,
            color: AppColors.primaryGold,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Shared frosted pill: “FOUNDER-LED • RICHMOND, VA” (app bar account).
class _FounderLedLocationChip extends StatelessWidget {
  const _FounderLedLocationChip({
    this.compact = false,
    this.textAlign = TextAlign.center,
  });

  final bool compact;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderColor),
        color: AppColors.bgCard.withValues(alpha: 0.45),
      ),
      child: Text(
        'FOUNDER-LED • RICHMOND, VA',
        textAlign: textAlign,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 9.5 : 11,
            ),
      ),
    );
  }
}

class _TopNavTabs extends StatefulWidget {
  const _TopNavTabs({
    required this.currentPath,
    required this.style,
    required this.tabLayerLinks,
    this.tabHoverIndicatorIndex,
    this.onNavTabHover,
    this.onNavTabHoverEnd,
  });

  final String currentPath;
  final TextStyle? style;
  final List<LayerLink> tabLayerLinks;
  final int? tabHoverIndicatorIndex;
  final void Function(String route, int tabIndex)? onNavTabHover;
  final void Function(String route)? onNavTabHoverEnd;

  @override
  State<_TopNavTabs> createState() => _TopNavTabsState();
}

class _TopNavTabsState extends State<_TopNavTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  int _indexForPath(String path) {
    if (path == AppRoutes.home) return 0;
    if (path == AppRoutes.services) return 1;
    if (path.startsWith(AppRoutes.portfolio)) return 2;
    if (path == AppRoutes.designPhilosophy) return 3;
    if (path == AppRoutes.about) return 4;
    if (path == AppRoutes.contact) return 5;
    if (path.startsWith(AppRoutes.insights)) return 6;
    return 0;
  }

  int get _targetIndex =>
      widget.tabHoverIndicatorIndex ?? _indexForPath(widget.currentPath);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _KNav.items.length,
      vsync: this,
      initialIndex: _targetIndex,
    );
  }

  @override
  void didUpdateWidget(covariant _TopNavTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath ||
        oldWidget.tabHoverIndicatorIndex != widget.tabHoverIndicatorIndex) {
      if (_tabController.index != _targetIndex) {
        _tabController.index = _targetIndex;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _navTab({
    required ({String label, String route, IconData icon}) item,
    required int index,
    required TextStyle? textStyle,
  }) {
    final child = Text(
      item.label,
      style: textStyle?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
    );
    if (widget.onNavTabHover == null) {
      return Tab(child: child);
    }
    return Tab(
      child: CompositedTransformTarget(
        link: widget.tabLayerLinks[index],
        child: MouseRegion(
          onEnter: (_) => widget.onNavTabHover?.call(item.route, index),
          onExit: (_) => widget.onNavTabHoverEnd?.call(item.route),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _KNav.items;
    final textStyle = widget.style;
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryGold,
        indicatorWeight: 2.4,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: textStyle,
        unselectedLabelStyle: textStyle,
        onTap: (index) => context.go(items[index].route),
        // Text-only on web + tablet; mobile nav uses the hamburger menu (icons kept there).
        tabs: <Widget>[
          for (var i = 0; i < items.length; i++)
            _navTab(
              item: items[i],
              index: i,
              textStyle: textStyle,
            ),
        ],
      ),
    );
  }
}

class _AccountMetaBlock extends StatelessWidget {
  const _AccountMetaBlock({this.mobile = false});

  /// Tighter layout + smaller type when shown in the mobile app bar.
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final double hPad = mobile ? 4 : 10;
    final double vPad = mobile ? 0 : 6;
    final double betweenRows = mobile ? 4 : 16;
    final double? labelSize = mobile ? 12 : null;

    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: labelSize,
        );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            mobile ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                mobile ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 4 : 10,
                    vertical: mobile ? 0 : 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Sign in', style: textStyle),
              ),
              Text(
                ' / ',
                style: textStyle?.copyWith(color: AppColors.primaryGold),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.signUp),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 4 : 10,
                    vertical: mobile ? 0 : 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Sign Up', style: textStyle),
              ),
            ],
          ),
          SizedBox(height: betweenRows),
          Align(
            alignment: mobile ? Alignment.centerRight : Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: _FounderLedLocationChip(
                compact: true,
                textAlign: mobile ? TextAlign.end : TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
