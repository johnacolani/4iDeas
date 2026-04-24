import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:go_router/go_router.dart';

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
  @override
  Widget build(BuildContext context) {
    final double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
                      _ModernTopAppBar(isMobile: isMobile),
                      SizedBox(height: isMobile ? 0 : 6),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    // Same home content on phone, tablet, and desktop (see [WebScreen]).
                    child: const WebScreen(),
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
  const _ModernTopAppBar({required this.isMobile});

  final bool isMobile;

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
          fontWeight: FontWeight.w500,
        );
    return Padding(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height:
                contentHeight + topInset + bottomContentPadding + contentTopNudge,
            // Horizontal insets: web/tablet left matches [WebScreen] home column gutter.
            padding: EdgeInsets.only(
              left: isMobile
                  ? 6.0
                  : AppBreakpoints.homeContentGutter,
              right: isMobile ? 6.0 : 24.0,
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
                              Image.asset('assets/images/logo.png',
                                  width: 44, height: 44),
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
                            Image.asset('assets/images/logo.png',
                                width: 52, height: 52),
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
        padding: EdgeInsets.zero,
        tooltip: 'Menu',
        onSelected: (route) => context.go(route),
        itemBuilder: (context) => _KNav.items
            .map(
              (e) => PopupMenuItem<String>(
                value: e.route,
                child: Row(
                  children: [
                    _NavGoldIcon(e.icon, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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

class _TopNavTabs extends StatelessWidget {
  const _TopNavTabs({
    required this.currentPath,
    required this.style,
  });

  final String currentPath;
  final TextStyle? style;

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

  @override
  Widget build(BuildContext context) {
    final items = _KNav.items;
    final selected = _indexForPath(currentPath);
    final textStyle = style;
    return DefaultTabController(
      key: ValueKey<String>(currentPath),
      initialIndex: selected,
      length: items.length,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 2.4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: textStyle,
          unselectedLabelStyle: textStyle,
          onTap: (index) => context.go(items[index].route),
          // Text-only on web + tablet; mobile nav uses the hamburger menu (icons kept there).
          tabs: items
              .map(
                (e) => Tab(
                  child: Text(
                    e.label,
                    style: textStyle?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ) ??
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
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
          mainAxisAlignment: mobile
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
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
