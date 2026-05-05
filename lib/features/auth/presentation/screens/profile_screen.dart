import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/order_service.dart';
import '../../../../app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> _orders = [];
  bool _isLoadingOrders = true;
  String? _ordersError;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });

    try {
      final orders = await _orderService.getUserOrdersOnce();
      if (mounted) {
        setState(() {
          _orders.clear();
          _orders.addAll(orders);
          _ordersError = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      if (mounted) {
        setState(() {
          _orders.clear();
          _ordersError = 'Failed to load orders: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final double horizontalPadding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                context.go(AppRoutes.home);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is Authenticated || state is EmailNotVerified) {
                final user = state is Authenticated
                    ? state.user
                    : (state as EmailNotVerified).user;

                return Padding(
                  padding: FrostedAppBar.contentPaddingUnderAppBar(context),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      primary: true,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isMobile ? 18 : 28,
                        horizontalPadding,
                        isMobile ? 28 : 44,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileHero(user, isMobile),
                              SizedBox(height: isMobile ? 18 : 24),
                              _buildMyOrdersSection(isMobile),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(User user, bool isMobile) {
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : 'Client';
    final email = user.email ?? 'No email added';
    final initials = _initialsFor(displayName, email);

    final avatar = Container(
      width: isMobile ? 76 : 92,
      height: isMobile ? 76 : 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.accentGold,
            ColorManager.primaryTeal,
            ColorManager.secondaryPurple.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.accentGold.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.roboto(
            color: ColorManager.onDarkPrimary,
            fontSize: isMobile ? 28 : 34,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusPill(
          icon: user.emailVerified
              ? Icons.verified_rounded
              : Icons.mark_email_unread_rounded,
          label: user.emailVerified ? 'Verified client' : 'Email pending',
          color: user.emailVerified
              ? Colors.greenAccent.shade400
              : ColorManager.accentGold,
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: GoogleFonts.roboto(
            color: ColorManager.onDarkPrimary,
            fontSize: isMobile ? 30 : 42,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _metaChip(Icons.alternate_email_rounded, email),
            _metaChip(
              Icons.shopping_bag_outlined,
              '${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'}',
            ),
          ],
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _heroActionButton(
          icon: Icons.add_circle_outline_rounded,
          label: 'Start Project',
          onPressed: () => context.go(AppRoutes.orderHere),
        ),
        _heroActionButton(
          icon: Icons.logout_rounded,
          label: 'Logout',
          destructive: true,
          onPressed: _showLogoutDialog,
        ),
      ],
    );

    return _glassPanel(
      borderColor: ColorManager.accentGold.withValues(alpha: 0.34),
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 18),
                identity,
                const SizedBox(height: 20),
                actions,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: identity),
                const SizedBox(width: 24),
                actions,
              ],
            ),
    );
  }

  Widget _buildMyOrdersSection(bool isMobile) {
    final signedContracts =
        _orders.where((order) => order['contractSigned'] == true).length;
    final paidOrders =
        _orders.where((order) => order['downPaymentPaid'] == true).length;
    final activeOrders = _orders
        .where(
            (order) => order['status']?.toString().toLowerCase() != 'completed')
        .length;

    return _glassPanel(
      borderColor: ColorManager.primaryTeal.withValues(alpha: 0.32),
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColorManager.primaryTeal.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorManager.primaryTeal.withValues(alpha: 0.26),
                  ),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: ColorManager.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Dashboard',
                      style: GoogleFonts.roboto(
                        color: ColorManager.onDarkPrimary,
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track orders, contracts, responses, and payments in one place.',
                      style: TextStyle(
                        color: ColorManager.onDarkSecondary,
                        fontSize: isMobile ? 13.5 : 15,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ColorManager.accentGold,
                  size: 24,
                ),
                onPressed: _isLoadingOrders ? null : _loadOrders,
                tooltip: 'Refresh orders',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summaryTile('Orders', _orders.length.toString(),
                  Icons.shopping_bag_outlined, ColorManager.accentGold),
              _summaryTile('Active', activeOrders.toString(),
                  Icons.bolt_rounded, ColorManager.primaryTeal),
              _summaryTile('Contracts', signedContracts.toString(),
                  Icons.description_outlined, ColorManager.secondaryPurple),
              _summaryTile('Paid', paidOrders.toString(),
                  Icons.payments_outlined, Colors.greenAccent.shade400),
            ],
          ),
          const SizedBox(height: 22),
          if (_isLoadingOrders)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: CircularProgressIndicator(
                  color: ColorManager.accentGold,
                ),
              ),
            )
          else if (_ordersError != null)
            _emptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load orders',
              message: _ordersError!,
              actionLabel: 'Retry',
              onPressed: _loadOrders,
              isMobile: isMobile,
            )
          else if (_orders.isEmpty)
            _emptyState(
              icon: Icons.auto_awesome_rounded,
              title: 'No projects yet',
              message:
                  'When you submit your first project request, it will appear here with contract and payment updates.',
              actionLabel: 'Start a project',
              onPressed: () => context.go(AppRoutes.orderHere),
              isMobile: isMobile,
            )
          else
            Column(
              children: [
                for (final order in _orders) _buildOrderCard(order, isMobile),
              ],
            ),
        ],
      ),
    );
  }

  Widget _summaryTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.roboto(
                  color: ColorManager.onDarkPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: ColorManager.onDarkSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassPanel({
    required Widget child,
    required EdgeInsetsGeometry padding,
    required Color borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF15120F).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statusPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ColorManager.accentGold, size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorManager.onDarkSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    final background = destructive
        ? ColorManager.accentCoral.withValues(alpha: 0.12)
        : ColorManager.accentGold;
    final foreground =
        destructive ? ColorManager.accentCoral : ColorManager.backgroundDark;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: destructive
              ? BorderSide(
                  color: ColorManager.accentCoral.withValues(alpha: 0.34),
                )
              : BorderSide.none,
        ),
        textStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 28,
        vertical: isMobile ? 26 : 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Icon(icon, color: ColorManager.accentGold, size: isMobile ? 42 : 52),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.roboto(
              color: ColorManager.onDarkPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: ColorManager.onDarkSecondary,
              fontSize: isMobile ? 13.5 : 15,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          _heroActionButton(
            icon: Icons.arrow_forward_rounded,
            label: actionLabel,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _orderTitle(String appName, String createdAt, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: GoogleFonts.roboto(
            color: ColorManager.textPrimary,
            fontSize: isMobile ? 19 : 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (createdAt.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            'Submitted ${createdAt.substring(0, createdAt.length > 10 ? 10 : createdAt.length)}',
            style: TextStyle(
              color: ColorManager.textMuted,
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _orderPills(
    String status,
    Color statusColor,
    String priority,
    bool hasPriority,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _lightChip(
          status.toUpperCase(),
          statusColor,
          Icons.radio_button_checked_rounded,
        ),
        if (hasPriority)
          _lightChip(priority, ColorManager.primaryTeal, Icons.flag_rounded),
      ],
    );
  }

  Widget _lightChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('complete') || normalized.contains('paid')) {
      return Colors.green.shade700;
    }
    if (normalized.contains('progress') || normalized.contains('review')) {
      return ColorManager.primaryTealPressed;
    }
    if (normalized.contains('cancel') || normalized.contains('reject')) {
      return Colors.red.shade600;
    }
    return ColorManager.accentGoldDark;
  }

  String _initialsFor(String displayName, String email) {
    final nameParts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (nameParts.isNotEmpty && displayName != 'Client') {
      return nameParts.take(2).map((part) => part[0].toUpperCase()).join();
    }
    if (email.isNotEmpty && email != 'No email added') {
      return email[0].toUpperCase();
    }
    return 'C';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.containerSurface,
        title: Text(
          'Logout',
          style: GoogleFonts.roboto(
            color: ColorManager.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: ColorManager.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ColorManager.primaryTeal),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.accentCoral,
              foregroundColor: ColorManager.backgroundDark,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isMobile) {
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    final appType = order['appType']?.toString() ?? '';
    final budget = order['budget']?.toString() ?? '';
    final timeline = order['timeline']?.toString() ?? '';
    final priority = order['priority']?.toString() ?? 'Normal';
    final status = order['status']?.toString() ?? 'pending';
    final createdAt = order['createdAt']?.toString() ?? '';
    final adminResponse = order['adminResponse']?.toString() ?? '';
    final hasAdminResponse = adminResponse.isNotEmpty;
    final contractSent = order['contractSent'] == true;
    final contractSigned = order['contractSigned'] == true;
    final contractNotes = order['contractNotes']?.toString() ?? '';

    final statusColor = _colorForStatus(status);
    final hasPriority =
        priority.isNotEmpty && priority.toLowerCase() != 'not specified';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: ColorManager.containerSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ColorManager.accentGold.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _orderTitle(appName, createdAt, isMobile),
            const SizedBox(height: 12),
            _orderPills(status, statusColor, priority, hasPriority),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _orderTitle(appName, createdAt, isMobile)),
                const SizedBox(width: 12),
                _orderPills(status, statusColor, priority, hasPriority),
              ],
            ),
          const SizedBox(height: 16),
          if (appType.isNotEmpty && appType != 'Not specified')
            _buildOrderDetailRow(
              Icons.category,
              'Type',
              appType,
              isMobile,
            ),
          if (budget.isNotEmpty && budget != 'Not specified')
            _buildOrderDetailRow(
              Icons.attach_money,
              'Budget',
              budget,
              isMobile,
            ),
          if (timeline.isNotEmpty && timeline != 'Not specified')
            _buildOrderDetailRow(
              Icons.schedule,
              'Timeline',
              timeline,
              isMobile,
            ),
          // Admin Response Section
          if (hasAdminResponse) ...[
            SizedBox(height: 16),
            Divider(color: ColorManager.containerBorder),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              decoration: BoxDecoration(
                color: ColorManager.containerSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade600.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 18,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Admin Response',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    adminResponse,
                    style: TextStyle(
                      color: ColorManager.textPrimary,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showReplyDialog(order, isMobile);
                      },
                      icon: Icon(Icons.reply, size: 18),
                      label: Text('Reply to Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryTeal,
                        foregroundColor: ColorManager.backgroundDark,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Contract Section
          if (contractSent) ...[
            SizedBox(height: 16),
            Divider(color: ColorManager.containerBorder),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              decoration: BoxDecoration(
                color: ColorManager.containerSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: contractSigned
                      ? Colors.green.shade600.withValues(alpha: 0.4)
                      : ColorManager.secondaryPurple.withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 18,
                        color: contractSigned
                            ? Colors.green.shade700
                            : ColorManager.secondaryPurple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Contract',
                        style: TextStyle(
                          color: contractSigned
                              ? Colors.green.shade700
                              : ColorManager.secondaryPurple,
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (contractSigned)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SIGNED',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (contractNotes.isNotEmpty) ...[
                    Text(
                      contractNotes,
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                  if (contractSigned) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'You have signed this contract',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: isMobile ? 12 : 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.contractView,
                          extra: order,
                        ),
                        icon: Icon(Icons.description, size: 18),
                        label: Text('View Full Contract'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorManager.secondaryPurple,
                          side: BorderSide(
                              color: ColorManager.secondaryPurple
                                  .withValues(alpha: 0.5)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Please review and sign the contract',
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showContractSignDialog(order, isMobile);
                        },
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Sign Contract'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.secondaryPurple,
                          foregroundColor: ColorManager.onDarkPrimary,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Payment Section (only visible after contract is signed)
          if (contractSigned) ...[
            Builder(
              builder: (context) {
                final downPaymentPaid = order['downPaymentPaid'] == true;
                final downPaymentAmount = order['downPaymentAmount'] ?? 0.0;
                return Column(
                  children: [
                    SizedBox(height: 16),
                    Divider(color: ColorManager.containerBorder),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 14),
                      decoration: BoxDecoration(
                        color: ColorManager.containerSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: downPaymentPaid
                              ? Colors.green.shade600.withValues(alpha: 0.4)
                              : ColorManager.accentGold.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment,
                                size: 18,
                                color: downPaymentPaid
                                    ? Colors.green.shade700
                                    : ColorManager.accentGoldDark,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Down Payment',
                                style: TextStyle(
                                  color: downPaymentPaid
                                      ? Colors.green.shade700
                                      : ColorManager.accentGoldDark,
                                  fontSize: isMobile ? 14 : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (downPaymentPaid)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PAID',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: isMobile ? 11 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          if (downPaymentPaid) ...[
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Down payment of \$${(downPaymentAmount as num).toStringAsFixed(2)} received',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: isMobile ? 12 : 13,
                                  ),
                                ),
                              ],
                            ),
                            if (order['transactionId']?.toString().isNotEmpty ==
                                true) ...[
                              SizedBox(height: 8),
                              Text(
                                'Transaction ID: ${order['transactionId']}',
                                style: TextStyle(
                                  color: ColorManager.textMuted,
                                  fontSize: isMobile ? 11 : 12,
                                ),
                              ),
                            ],
                          ] else ...[
                            Text(
                              'Complete your down payment to proceed',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 13 : 14,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push(
                                  AppRoutes.payment,
                                  extra: {
                                    'order': order,
                                    'onSuccess': _loadOrders
                                  },
                                ),
                                icon: Icon(Icons.payment, size: 18),
                                label: Text('Make Down Payment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.primaryTeal,
                                  foregroundColor: ColorManager.backgroundDark,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> order, bool isMobile) {
    final TextEditingController replyController = TextEditingController();
    final orderId = order['id'] as String;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ColorManager.containerSurface,
              title: Row(
                children: [
                  Icon(Icons.reply, color: ColorManager.primaryTeal),
                  SizedBox(width: 8),
                  Text(
                    'Reply to Admin',
                    style: GoogleFonts.roboto(
                      color: ColorManager.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: ${order['appName']?.toString() ?? 'Untitled'}',
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: replyController,
                      maxLines: 6,
                      style: TextStyle(color: ColorManager.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type your response...',
                        hintStyle: TextStyle(color: ColorManager.textMuted),
                        filled: true,
                        fillColor: ColorManager.containerSurfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: ColorManager.containerBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: ColorManager.containerBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: ColorManager.primaryTeal, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          context.pop();
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: ColorManager.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (replyController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a message'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _orderService.addClientResponse(
                              orderId: orderId,
                              response: replyController.text.trim(),
                            );

                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Response sent successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadOrders(); // Refresh orders
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to send response: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() {
                                isSubmitting = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryTeal,
                    foregroundColor: ColorManager.backgroundDark,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.backgroundDark),
                          ),
                        )
                      : Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showContractSignDialog(Map<String, dynamic> order, bool isMobile) {
    final orderId = order['id'] as String;
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    bool isSigning = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ColorManager.containerSurface,
              title: Row(
                children: [
                  Icon(Icons.description, color: ColorManager.secondaryPurple),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sign Contract',
                      style: GoogleFonts.roboto(
                        color: ColorManager.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: $appName',
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'By clicking "Sign Contract", you agree to the terms and conditions of this contract.',
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSigning
                      ? null
                      : () {
                          context.pop();
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: ColorManager.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSigning
                      ? null
                      : () async {
                          setState(() {
                            isSigning = true;
                          });

                          try {
                            await _orderService.markContractSigned(
                                orderId: orderId);

                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contract signed successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadOrders(); // Refresh orders
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to sign contract: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() {
                                isSigning = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryPurple,
                    foregroundColor: ColorManager.onDarkPrimary,
                  ),
                  child: isSigning
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.onDarkPrimary),
                          ),
                        )
                      : Text('Sign Contract'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOrderDetailRow(
      IconData icon, String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: ColorManager.textMuted,
          ),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: ColorManager.textSecondary,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ColorManager.textPrimary,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
