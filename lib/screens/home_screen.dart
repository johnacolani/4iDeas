import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:go_router/go_router.dart';

import '../helper/app_background.dart';
import '../core/design_system/responsive.dart';
import '../core/design_system/theme.dart';
import '../widgets/home_mobile_nav_menu_button.dart';

/// Top inset for the floating [HomeMobileNavMenuButton] (matches [WebScreen] narrow top reserve).
const double _kFloatingMobileNavTop = 4.0;

const LinearGradient _kNavIconGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[
    AppColors.primaryGold,
    AppColors.primaryGoldDark,
  ],
);

bool _pathIsServicesHub(String path) {
  if (path == AppRoutes.services) return true;
  if (path.startsWith(AppRoutes.portfolio)) return true;
  if (path == AppRoutes.designPhilosophy) return true;
  if (path.startsWith(AppRoutes.insights)) return true;
  if (path == AppRoutes.caseStudies) return true;
  return false;
}

/// Which primary slot (0–3) shows the gold underline: Home, Services, About, Contact.
int _primaryHighlightIndex(String path) {
  final p = path.isEmpty ? '/' : path;
  if (p == AppRoutes.home) return 0;
  if (_pathIsServicesHub(p)) return 1;
  if (p == AppRoutes.about) return 2;
  if (p == AppRoutes.contact) return 3;
  return -1;
}

/// ~10% narrower than prior desktop widths (274 ≈ 304×0.9, 241 ≈ 268×0.9).
const double _kServicesMenuMinWidth = 274;
const double _kAdminMenuMinWidth = 241;
/// Dividers between dropdown rows (Services, Admin, hamburger).
const Color _kPopupMenuDividerColor = Color(0xFF3F3F46);

/// Lighter hover / splash for menu rows: soft blue tint (replaces flat white 8%).
const Color _kPopupMenuHoverColor = Color(0x1A7AB6F5);

/// Desktop nav dropdown rows: roomier tap targets, labels shifted further left.
const EdgeInsets _kDesktopPopupMenuItemPadding =
    EdgeInsets.symmetric(horizontal: 22, vertical: 14);

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
  /// Desktop only: which primary slot (0–3) shows the gold underline while hovering.
  int? _hoveredPrimaryIndex;

  void _onNavTabHoverStart(String route, int tabIndex) {
    setState(() => _hoveredPrimaryIndex = tabIndex);
  }

  void _onNavTabHoverEnd(String route) {
    setState(() => _hoveredPrimaryIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final bool desktopNavHover = !isMobile;

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
                        tabHoverIndicatorIndex: desktopNavHover
                            ? _hoveredPrimaryIndex
                            : null,
                        onNavTabHover:
                            desktopNavHover ? _onNavTabHoverStart : null,
                        onNavTabHoverEnd:
                            desktopNavHover ? _onNavTabHoverEnd : null,
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
                      alignment: Alignment.topLeft,
                      children: [
                        const WebScreen(),
                        if (Responsive.isMobile(context))
                          Positioned(
                            left: 10,
                            top: _kFloatingMobileNavTop,
                            child: const HomeMobileNavMenuButton(),
                          ),
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
    this.tabHoverIndicatorIndex,
    this.onNavTabHover,
    this.onNavTabHoverEnd,
  });

  final bool isMobile;
  final int? tabHoverIndicatorIndex;
  final void Function(String route, int tabIndex)? onNavTabHover;
  final void Function(String route)? onNavTabHoverEnd;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final topInset = MediaQuery.paddingOf(context).top;
    final double viewportWidth = MediaQuery.sizeOf(context).width;
    // Vertical space for logo / tabs / account; mobile = logo + menu column.
    const double baseBarContentHeight = 76;
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 44,
                                height: 44,
                              ),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrimaryDesktopNav(
                          currentPath: currentPath,
                          style: navStyle,
                          tabHoverIndicatorIndex: tabHoverIndicatorIndex,
                          onNavTabHover: onNavTabHover,
                          onNavTabHoverEnd: onNavTabHoverEnd,
                        ),
                      ),
                      const SizedBox(width: 44),
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

class _NavUnderlineLink extends StatelessWidget {
  const _NavUnderlineLink({
    required this.label,
    required this.route,
    required this.layerIndex,
    required this.selected,
    required this.textStyle,
    this.onNavTabHover,
    this.onNavTabHoverEnd,
  });

  final String label;
  final String route;
  final int layerIndex;
  final bool selected;
  final TextStyle textStyle;
  final void Function(String route, int tabIndex)? onNavTabHover;
  final void Function(String route)? onNavTabHoverEnd;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: onNavTabHover != null
          ? (_) => onNavTabHover!(route, layerIndex)
          : null,
      onExit: onNavTabHoverEnd != null
          ? (_) => onNavTabHoverEnd!(route)
          : null,
      child: TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2.4,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryGold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _HoverNavMenuPanelBuilder =
    Widget Function(BuildContext context, VoidCallback closeMenu);

/// Desktop only: opens below the trigger on hover (no click required).
class _DesktopHoverNavDropdown extends StatefulWidget {
  const _DesktopHoverNavDropdown({
    required this.trigger,
    required this.menuMinWidth,
    required this.menuBuilder,
  });

  final Widget trigger;
  final double menuMinWidth;
  final _HoverNavMenuPanelBuilder menuBuilder;

  @override
  State<_DesktopHoverNavDropdown> createState() =>
      _DesktopHoverNavDropdownState();
}

class _DesktopHoverNavDropdownState extends State<_DesktopHoverNavDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  static const Duration _closeDelay = Duration(milliseconds: 240);

  void _cancelCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _cancelCloseTimer();
    _closeTimer = Timer(_closeDelay, () {
      if (!mounted) return;
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _cancelCloseTimer();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeMenu() {
    _removeOverlay();
  }

  void _insertOverlay() {
    if (_overlayEntry != null || !mounted) return;
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 6),
              child: MouseRegion(
                onEnter: (_) => _cancelCloseTimer(),
                onExit: (_) => _scheduleClose(),
                child: Material(
                  elevation: 12,
                  shadowColor: Colors.black54,
                  color: const Color(0xFF111827),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: widget.menuMinWidth,
                    ),
                    child: IntrinsicWidth(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          highlightColor: _kPopupMenuHoverColor,
                          hoverColor: _kPopupMenuHoverColor,
                          dividerTheme: const DividerThemeData(
                            color: _kPopupMenuDividerColor,
                            thickness: 1,
                          ),
                        ),
                        child: widget.menuBuilder(
                          overlayContext,
                          _closeMenu,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlayState.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _cancelCloseTimer();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          _cancelCloseTimer();
          _insertOverlay();
        },
        onExit: (_) => _scheduleClose(),
        child: widget.trigger,
      ),
    );
  }
}

class _PrimaryDesktopNav extends StatelessWidget {
  const _PrimaryDesktopNav({
    required this.currentPath,
    required this.style,
    this.tabHoverIndicatorIndex,
    this.onNavTabHover,
    this.onNavTabHoverEnd,
  });

  final String currentPath;
  final TextStyle? style;
  final int? tabHoverIndicatorIndex;
  final void Function(String route, int tabIndex)? onNavTabHover;
  final void Function(String route)? onNavTabHoverEnd;

  static bool _adminTabSelected(String path) {
    return path == AppRoutes.adminOrders ||
        path.startsWith('${AppRoutes.adminOrders}/');
  }

  @override
  Widget build(BuildContext context) {
    final path = currentPath.isEmpty ? AppRoutes.home : currentPath;
    final baseHi = _primaryHighlightIndex(path);
    final hi = tabHoverIndicatorIndex ?? baseHi;

    final textStyle = style ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userEmail = authState is Authenticated
            ? authState.user.email
            : authState is EmailNotVerified
                ? authState.user.email
                : null;
        final showAdmin =
            userEmail != null && AdminService.isAdmin(email: userEmail);
        final adminSel = _adminTabSelected(path);

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavUnderlineLink(
                  label: 'Home',
                  route: AppRoutes.home,
                  layerIndex: 0,
                  selected: hi == 0,
                  textStyle: textStyle,
                  onNavTabHover: onNavTabHover,
                  onNavTabHoverEnd: onNavTabHoverEnd,
                ),
                MouseRegion(
                  onEnter: onNavTabHover != null
                      ? (_) => onNavTabHover!(AppRoutes.services, 1)
                      : null,
                  onExit: onNavTabHoverEnd != null
                      ? (_) => onNavTabHoverEnd!(AppRoutes.services)
                      : null,
                  child: _DesktopHoverNavDropdown(
                    menuMinWidth: _kServicesMenuMinWidth,
                    menuBuilder: (ctx, close) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0;
                              i < HomeNavMenuItems.servicesHubItems.length;
                              i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: _kPopupMenuDividerColor,
                              ),
                            InkWell(
                              onTap: () {
                                close();
                                ctx.go(
                                  HomeNavMenuItems.servicesHubItems[i].route,
                                );
                              },
                              child: Padding(
                                padding: _kDesktopPopupMenuItemPadding,
                                child: Row(
                                  children: [
                                    _NavGoldIcon(
                                      HomeNavMenuItems.servicesHubItems[i].icon,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        HomeNavMenuItems.servicesHubItems[i].label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    trigger: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Services',
                                  style: textStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2.4,
                              decoration: BoxDecoration(
                                color: hi == 1
                                    ? AppColors.primaryGold
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _NavUnderlineLink(
                  label: 'About',
                  route: AppRoutes.about,
                  layerIndex: 2,
                  selected: hi == 2,
                  textStyle: textStyle,
                  onNavTabHover: onNavTabHover,
                  onNavTabHoverEnd: onNavTabHoverEnd,
                ),
                _NavUnderlineLink(
                  label: 'Contact Us',
                  route: AppRoutes.contact,
                  layerIndex: 3,
                  selected: hi == 3,
                  textStyle: textStyle,
                  onNavTabHover: onNavTabHover,
                  onNavTabHoverEnd: onNavTabHoverEnd,
                ),
                if (showAdmin) ...[
                  const SizedBox(width: 8),
                  _DesktopHoverNavDropdown(
                    menuMinWidth: _kAdminMenuMinWidth,
                    menuBuilder: (ctx, close) {
                      Widget row({
                        required String route,
                        required String label,
                        required IconData icon,
                      }) {
                        return InkWell(
                          onTap: () {
                            close();
                            ctx.go(route);
                          },
                          child: Padding(
                            padding: _kDesktopPopupMenuItemPadding,
                            child: Row(
                              children: [
                                _NavGoldIcon(icon, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          row(
                            route: AppRoutes.profile,
                            label: 'Profile',
                            icon: Icons.person_outline,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _kPopupMenuDividerColor,
                          ),
                          row(
                            route: AppRoutes.adminOrders,
                            label: 'Admin orders',
                            icon: Icons.admin_panel_settings_outlined,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _kPopupMenuDividerColor,
                          ),
                          row(
                            route: AppRoutes.contact,
                            label: 'Contact inbox',
                            icon: Icons.mark_chat_unread_outlined,
                          ),
                        ],
                      );
                    },
                    trigger: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Admin',
                                  style: textStyle.copyWith(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primaryGold,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2.4,
                              decoration: BoxDecoration(
                                color: adminSel
                                    ? AppColors.primaryGold
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated ||
                  authState is EmailNotVerified) {
                final userEmail = authState is Authenticated
                    ? authState.user.email
                    : (authState as EmailNotVerified).user.email;
                final sepStyle =
                    textStyle?.copyWith(color: AppColors.primaryGold);
                final emailStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: mobile ? 10.5 : 11.5,
                      fontWeight: FontWeight.w500,
                    );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: mobile
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      alignment: mobile
                          ? WrapAlignment.end
                          : WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2,
                      runSpacing: 4,
                      children: [
                        TextButton(
                          onPressed: () => context.go(AppRoutes.profile),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGold,
                            padding: EdgeInsets.symmetric(
                              horizontal: mobile ? 4 : 10,
                              vertical: mobile ? 0 : 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Profile', style: textStyle),
                        ),
                        Text('·', style: sepStyle),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.profile),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGold,
                            padding: EdgeInsets.symmetric(
                              horizontal: mobile ? 4 : 10,
                              vertical: mobile ? 0 : 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('My orders', style: textStyle),
                        ),
                      ],
                    ),
                    SizedBox(height: mobile ? 3 : 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        userEmail ?? '',
                        textAlign:
                            mobile ? TextAlign.end : TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: emailStyle,
                      ),
                    ),
                  ],
                );
              }
              return Row(
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
              );
            },
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
