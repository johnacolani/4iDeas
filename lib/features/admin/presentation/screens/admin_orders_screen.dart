import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/order_service.dart';
import '../../../../app_router.dart';
import 'package:go_router/go_router.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!AdminService.isAdmin()) {
      // Redirect if not admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin only.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.getAllOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load orders: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    if (!AdminService.isAdmin()) {
      return Scaffold(
        appBar: FrostedAppBar.gold(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 56,
          title: Text(
            'Access Denied',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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
        ),
        body: Center(
          child: Text(
            'Admin access required',
            style: TextStyle(color: ColorManager.textSecondary),
          ),
        ),
      );
    }

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
          'Admin - Client Orders',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ColorManager.backgroundDark),
            onPressed: _isLoading ? null : _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 16 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadOrders,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primaryTeal,
                                foregroundColor: ColorManager.backgroundDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 60,
                                  color: ColorManager.textMuted,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No orders yet',
                                  style: TextStyle(
                                    color: ColorManager.textSecondary,
                                    fontSize: isMobile ? 18 : 20,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              padding: EdgeInsets.all(isMobile ? 16 : 24),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return _buildOrderCard(order, isMobile);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isMobile) {
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    final clientName = order['clientName']?.toString() ?? 'Unknown';
    final clientEmail = order['clientEmail']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'pending';
    final createdAt = order['createdAt']?.toString() ?? '';
    final hasResponse = order['adminResponse'] != null &&
        order['adminResponse'].toString().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: ColorManager.adminPanelCardDecoration(borderRadius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            AppRoutes.adminOrderDetail,
            extra: {'order': order, 'onResponseAdded': _loadOrders},
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: GoogleFonts.roboto(
                              color: ColorManager.textPrimary,
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Client: $clientName',
                            style: TextStyle(
                              color: ColorManager.textSecondary,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                          Text(
                            clientEmail,
                            style: TextStyle(
                              color: ColorManager.textMuted,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: hasResponse
                                ? Colors.green.withValues(alpha: 0.22)
                                : ColorManager.accentGold
                                    .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hasResponse ? 'Responded' : status.toUpperCase(),
                            style: TextStyle(
                              color: hasResponse
                                  ? Colors.green.shade700
                                  : ColorManager.accentGoldDark,
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (createdAt.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            createdAt.length > 19
                                ? createdAt.substring(0, 19)
                                : createdAt,
                            style: TextStyle(
                              color: ColorManager.textMuted,
                              fontSize: isMobile ? 10 : 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (hasResponse) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Response sent',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
