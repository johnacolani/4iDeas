import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_state.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared with [HomeNavMenuItems] for desktop Services dropdown in `home_screen.dart`.
class HomeNavMenuItems {
  HomeNavMenuItems._();

  static final List<({String label, String route, IconData icon})> servicesHubItems =
      <({String label, String route, IconData icon})>[
    (
      label: 'Services overview',
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
      label: 'How 4iDeas helps',
      route: AppRoutes.caseStudies,
      icon: Icons.auto_awesome_outlined,
    ),
    (
      label: 'Blog',
      route: AppRoutes.insights,
      icon: Icons.article_outlined,
    ),
  ];
}

const LinearGradient _kNavIconGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[
    AppColors.primaryGold,
    AppColors.primaryGoldDark,
  ],
);

const double _kHamburgerMenuMinWidth = 216;

const Color _kPopupMenuDividerColor = Color(0xFF3F3F46);
const Color _kPopupMenuHoverColor = Color(0x1A7AB6F5);

const TextStyle _labelStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

/// Hub / admin submenu rows (aligned with desktop dropdown typography).
const TextStyle _submenuLabelStyle = TextStyle(
  color: Colors.white,
  fontSize: 15.5,
  fontWeight: FontWeight.w600,
);

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

/// Home-only mobile / narrow navigation menu (pinned below the app bar on home).
/// On **web**, desktop opens on hover; **tap toggles** everywhere (required for mobile browsers).
///
/// When [overlayAlignToTrailing] is true, the dropdown anchors to the icon’s trailing
/// edge (use when the chip sits on the right side of the screen).
class HomeMobileNavMenuButton extends StatefulWidget {
  const HomeMobileNavMenuButton({
    super.key,
    this.overlayAlignToTrailing = false,
  });

  final bool overlayAlignToTrailing;

  @override
  State<HomeMobileNavMenuButton> createState() =>
      _HomeMobileNavMenuButtonState();
}

class _HomeMobileNavMenuButtonState extends State<HomeMobileNavMenuButton> {
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
      if (mounted) _removeOverlay();
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

  /// Pointer-leave dismiss only on web; touch menus stay open until tap outside.
  Widget _maybeHoverDismissRegion({required Widget child}) {
    if (!kIsWeb) return child;
    return MouseRegion(
      onEnter: (_) => _cancelCloseTimer(),
      onExit: (_) => _scheduleClose(),
      child: child,
    );
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _insertOverlay();
    }
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
              targetAnchor: widget.overlayAlignToTrailing
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              followerAnchor: widget.overlayAlignToTrailing
                  ? Alignment.topRight
                  : Alignment.topLeft,
              offset: const Offset(0, 6),
              child: _maybeHoverDismissRegion(
                child: Material(
                  elevation: 12,
                  shadowColor: Colors.black54,
                  color: const Color(0xFF111827),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: _kHamburgerMenuMinWidth,
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
                        child: _MobileNavDropdownBody(
                          onClose: _closeMenu,
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
    const icon = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Icon(
        Icons.menu,
        color: AppColors.primaryGold,
        size: 28,
      ),
    );

    // Web: desktop uses hover to open; phones and tablets using mobile browsers
    // need tap — they report kIsWeb but do not emit hover like a mouse.
    late final Widget trigger;
    if (kIsWeb) {
      trigger = MouseRegion(
        onEnter: (_) {
          _cancelCloseTimer();
          _insertOverlay();
        },
        onExit: (_) => _scheduleClose(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleOverlay,
          child: icon,
        ),
      );
    } else {
      trigger = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleOverlay,
        child: icon,
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: trigger,
    );
  }
}

/// Narrow-layout nav panel: Services and Admin/Account submenus expand **below**
/// their headers. Submenus open/close **only on tap** (including web)—hover does
/// not expand them. The parent opens from hover (desktop web) and tap (touch / mobile web).
class _MobileNavDropdownBody extends StatefulWidget {
  const _MobileNavDropdownBody({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_MobileNavDropdownBody> createState() => _MobileNavDropdownBodyState();
}

class _MobileNavDropdownBodyState extends State<_MobileNavDropdownBody> {
  bool _servicesExpanded = false;
  bool _accountExpanded = false;

  static const EdgeInsets _rowPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static const EdgeInsets _hubRowPadding =
      EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10);

  void _toggleServices() {
    setState(() {
      _servicesExpanded = !_servicesExpanded;
      if (_servicesExpanded) _accountExpanded = false;
    });
  }

  void _toggleAccount() {
    setState(() {
      _accountExpanded = !_accountExpanded;
      if (_accountExpanded) _servicesExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userEmail = authState is Authenticated
        ? authState.user.email
        : authState is EmailNotVerified
            ? authState.user.email
            : null;
    final showAdmin =
        userEmail != null && AdminService.isAdmin(email: userEmail);
    final signedIn =
        authState is Authenticated || authState is EmailNotVerified;

    void go(String route) {
      widget.onClose();
      context.go(route);
    }

    Widget primaryNavRow({
      required String route,
      required String label,
      required IconData icon,
    }) {
      return InkWell(
        hoverColor: _kPopupMenuHoverColor,
        onTap: () => go(route),
        child: Padding(
          padding: _rowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _labelStyle),
              _NavGoldIcon(icon, size: 22),
            ],
          ),
        ),
      );
    }

    Widget hubSubRow({
      required String route,
      required String label,
      required IconData icon,
    }) {
      return InkWell(
        hoverColor: _kPopupMenuHoverColor,
        onTap: () => go(route),
        child: Padding(
          padding: _hubRowPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NavGoldIcon(icon, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: _submenuLabelStyle)),
            ],
          ),
        ),
      );
    }

    Widget goldAccountRow({
      required String route,
      required String label,
      required IconData icon,
    }) {
      return InkWell(
        hoverColor: _kPopupMenuHoverColor,
        onTap: () => go(route),
        child: Padding(
          padding: _hubRowPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: AppColors.primaryGold,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget expandableHeader({
      required String label,
      required bool expanded,
      VoidCallback? onTap,
      TextStyle labelStyle = _labelStyle,
      Color chevronColor = Colors.white,
    }) {
      return InkWell(
        hoverColor: _kPopupMenuHoverColor,
        onTap: onTap,
        child: Padding(
          padding: _rowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: labelStyle),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: chevronColor,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }

    final goldHeaderStyle = GoogleFonts.roboto(
      color: AppColors.primaryGold,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    final servicesSubmenuItems = <Widget>[
      for (var i = 0; i < HomeNavMenuItems.servicesHubItems.length; i++) ...[
        if (i > 0)
          const Divider(
            height: 1,
            thickness: 1,
            color: _kPopupMenuDividerColor,
          ),
        hubSubRow(
          route: HomeNavMenuItems.servicesHubItems[i].route,
          label: HomeNavMenuItems.servicesHubItems[i].label,
          icon: HomeNavMenuItems.servicesHubItems[i].icon,
        ),
      ],
    ];

    final List<Widget>? adminSubmenuItems = signedIn && showAdmin
        ? <Widget>[
            hubSubRow(
              route: AppRoutes.profile,
              label: 'Profile',
              icon: Icons.person_outline,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: _kPopupMenuDividerColor,
            ),
            hubSubRow(
              route: AppRoutes.adminOrders,
              label: 'Admin orders',
              icon: Icons.admin_panel_settings_outlined,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: _kPopupMenuDividerColor,
            ),
            hubSubRow(
              route: AppRoutes.contact,
              label: 'Contact inbox',
              icon: Icons.mark_chat_unread_outlined,
            ),
          ]
        : null;

    final List<Widget>? accountSubmenuItems = signedIn && !showAdmin
        ? <Widget>[
            goldAccountRow(
              route: AppRoutes.profile,
              label: 'Profile',
              icon: Icons.person_outline,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: _kPopupMenuDividerColor,
            ),
            goldAccountRow(
              route: AppRoutes.profile,
              label: 'My orders',
              icon: Icons.receipt_long_outlined,
            ),
          ]
        : null;

    final children = <Widget>[
      primaryNavRow(
        route: AppRoutes.home,
        label: 'Home',
        icon: Icons.home_rounded,
      ),
      const Divider(height: 1, thickness: 1, color: _kPopupMenuDividerColor),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          expandableHeader(
            label: 'Services',
            expanded: _servicesExpanded,
            onTap: _toggleServices,
          ),
          if (_servicesExpanded) ...servicesSubmenuItems,
        ],
      ),
      const Divider(height: 1, thickness: 1, color: _kPopupMenuDividerColor),
      primaryNavRow(
        route: AppRoutes.about,
        label: 'About',
        icon: Icons.info_outlined,
      ),
      primaryNavRow(
        route: AppRoutes.contact,
        label: 'Contact Us',
        icon: Icons.mail_outlined,
      ),
    ];

    if (adminSubmenuItems != null) {
      children.add(
        const Divider(height: 1, thickness: 1, color: _kPopupMenuDividerColor),
      );
      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            expandableHeader(
              label: 'Admin',
              expanded: _accountExpanded,
              labelStyle: goldHeaderStyle,
              chevronColor: AppColors.primaryGold,
              onTap: _toggleAccount,
            ),
            if (_accountExpanded) ...adminSubmenuItems,
          ],
        ),
      );
    } else if (accountSubmenuItems != null) {
      children.add(
        const Divider(height: 1, thickness: 1, color: _kPopupMenuDividerColor),
      );
      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            expandableHeader(
              label: 'Account',
              expanded: _accountExpanded,
              labelStyle: goldHeaderStyle,
              chevronColor: AppColors.primaryGold,
              onTap: _toggleAccount,
            ),
            if (_accountExpanded) ...accountSubmenuItems,
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
