import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/order_service.dart';
import '../../../../app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
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
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        backgroundColor: ColorManager.accentGold,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.backgroundDark),
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
          style: GoogleFonts.albertSans(
            color: ColorManager.backgroundDark,
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

                return SafeArea(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User Info Card
                        _buildUserInfoCard(user, isMobile, he),
                        SizedBox(height: he * 0.02),

                        // My Orders Section
                        _buildMyOrdersSection(isMobile, he),
                      ],
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

  Widget _buildUserInfoCard(user, bool isMobile, double he) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.primaryTeal,
                ),
                child: Icon(
                  Icons.person,
                  color: ColorManager.backgroundDark,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'User',
                      style: GoogleFonts.albertSans(
                        color: ColorManager.textPrimary,
                        fontSize: isMobile ? 22 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email ?? 'No email',
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: he * 0.02),
          Divider(
            color: ColorManager.containerBorder,
            thickness: 1,
          ),
          SizedBox(height: he * 0.015),
          Row(
            children: [
              Icon(
                user.emailVerified
                    ? Icons.verified
                    : Icons.warning_amber_rounded,
                color: user.emailVerified ? Colors.green : Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                user.emailVerified ? 'Email Verified' : 'Email Not Verified',
                style: TextStyle(
                  color: user.emailVerified ? Colors.green : Colors.orange,
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: he * 0.02),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: ColorManager.containerSurface,
                    title: Text(
                      'Logout',
                      style: GoogleFonts.albertSans(
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
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryTeal,
                foregroundColor: ColorManager.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: GoogleFonts.albertSans(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersSection(bool isMobile, double he) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: ColorManager.accentGoldDark,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'My Orders',
                  style: GoogleFonts.albertSans(
                    color: ColorManager.textPrimary,
                    fontSize: isMobile ? 22 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: ColorManager.primaryTeal,
                  size: 24,
                ),
                onPressed: _isLoadingOrders ? null : _loadOrders,
                tooltip: 'Refresh orders',
              ),
            ],
          ),
          SizedBox(height: he * 0.02),
          if (_isLoadingOrders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_ordersError != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: he * 0.02),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Error loading orders',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.9),
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _ordersError!,
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                        fontSize: isMobile ? 13 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryTeal,
                      foregroundColor: ColorManager.backgroundDark,
                    ),
                  ),
                ],
              ),
            )
          else if (_orders.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: he * 0.02),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 60,
                    color: ColorManager.textMuted,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      color: ColorManager.textSecondary,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your submitted orders will appear here',
                    style: TextStyle(
                      color: ColorManager.textMuted,
                      fontSize: isMobile ? 14 : 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._orders.map((order) => _buildOrderCard(order, isMobile, he)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isMobile, double he) {
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

    return Container(
      margin: EdgeInsets.only(bottom: he * 0.015),
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: ColorManager.orderFormCardDecoration(borderRadius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appName,
                  style: GoogleFonts.albertSans(
                    color: ColorManager.textPrimary,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorManager.primaryTeal.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority.isNotEmpty && priority != 'Not specified'
                      ? priority
                      : 'Normal',
                  style: TextStyle(
                    color: ColorManager.primaryTeal,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
          if (status.isNotEmpty)
            _buildOrderDetailRow(
              Icons.info_outline,
              'Status',
              status.toUpperCase(),
              isMobile,
            ),
          if (createdAt.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Submitted: ${createdAt.substring(0, createdAt.length > 19 ? 19 : createdAt.length)}',
                style: TextStyle(
                  color: ColorManager.textMuted,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
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
                        color: contractSigned ? Colors.green.shade700 : ColorManager.secondaryPurple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Contract',
                        style: TextStyle(
                          color: contractSigned ? Colors.green.shade700 : ColorManager.secondaryPurple,
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
                              color: ColorManager.secondaryPurple.withValues(alpha: 0.5)),
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
                                  extra: {'order': order, 'onSuccess': _loadOrders},
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
                    style: GoogleFonts.albertSans(
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
                        hintStyle: TextStyle(
                            color: ColorManager.textMuted),
                        filled: true,
                        fillColor: ColorManager.containerSurfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: ColorManager.containerBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: ColorManager.containerBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: ColorManager.primaryTeal, width: 2),
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
                    style:
                        TextStyle(color: ColorManager.textMuted),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(ColorManager.backgroundDark),
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
                      style: GoogleFonts.albertSans(
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
                    style:
                        TextStyle(color: ColorManager.textMuted),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(ColorManager.onDarkPrimary),
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
